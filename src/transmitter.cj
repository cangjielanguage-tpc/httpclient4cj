/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Transmitter class.
 */
package okhttp

from std import sync.*
from std import math.*

/**
 * The class is Transmitter
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Transmitter {
    /* var member client type is OkHttpClient */
    private var client: OkHttpClient
    /* var member connectionPool type is ConnectionPool */
    private var connectionPool: ConnectionPool
    /* var member call type is Call */
    private var call: Call
    /* var member canceled */
    private var canceled = false
    /** var member connection type is Option<Connection> */
    public var connection: Option<Connection> = Option<Connection>.None
    /* var member request type is Option<Request> */
    private var request: Option<Request> = Option<Request>.None
    /* var member address type is Address */
    private var address: Address = Address(URL.parse(""), ArrayList<String>(), Option<TlsClientConfig> .None)
    /* var member exchangeFinder type is Option<ExchangeFinder> */
    private var exchangeFinder: Option<ExchangeFinder> = None
    /* var member exchange type is Option<Exchange> */
    private var exchange: Option<Exchange> = None

    private var noExchanges: Bool = false
    private var exchangeRequestDone: Bool = false
    private var exchangeResponseDone: Bool = false

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @param call of Call
     * @since 0.29.3
     */
    public init (client: OkHttpClient, call: Call) {
        this.client = client
        this.connectionPool = client.getConnectionPool() ?? ConnectionPool()
        this.call = call
    }

    /**
     * The Function is cancel
     *
     * @since 0.29.3
     */
    public func cancel(): Unit {
        let exchangeToCancel: Option<Exchange>
        let connectionToCancel: Option<Connection>
        synchronized (connectionPool.mutex) {
            canceled = true
            exchangeToCancel = exchange
            connectionToCancel = match (exchangeFinder) {
                case Some(find) =>
                    match (find.getConnectingConnection()) {
                        case Some(conn) => Option<Connection>.Some(conn)
                        case None => this.connection
                    }
                case None => this.connection
            }
        }
        match(exchangeToCancel) {
            case Some(cancelEx) => cancelEx.cancel()
            case None =>
                match (connectionToCancel) {
                    case Some(cancelConn) => cancelConn.cancel()
                    case None => ()
                }
        }
    }

    /**
     * The Function is isCanceled
     *
     * @since 0.29.3
     */
    public func isCanceled(): Bool {
        synchronized (connectionPool.mutex) {
            return canceled
        }
    }

    /**
     * The Function is releaseConnectionNoEvents
     *
     * @return Type of Option<Socket>
     * @since 0.29.3
     */
     func releaseConnectionNoEvents(): Option<Socket> {
        let conn = connection.getOrThrow()
        let arr = conn.getTransmitters()
        for (index in 0..arr.size()) {
            if (refEq(arr[index],this)) {
                arr.remove(index)
                break
            }
        }
        let released = conn
        this.connection = Option<Connection>.None
        if (arr.isEmpty()) {
           released.idleAtNanos = Time.now()
           if (connectionPool.connectionBecameIdle(released)) {
               return released.getSocket()
           }
        }

        return Option<Socket>.None
    }

    /**
     * The Function is acquireConnectionNoEvents
     *
     * @param connection of Connection
     *
     * @return Type of Unit
     * @since 0.29.3
     */
     func acquireConnectionNoEvents(connection: Option<Connection>): Unit {
        synchronized (connectionPool.mutex) {
            match (connection) {
                case Some(conn) => ()
                    this.connection =  conn
                    conn.transmitters.append(this)
                case None => throw HttpException("IllegalStateException")
            }
        }
    }

    /**
     * The Function is prepareToConnect
     *
     * @param request of Request
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func prepareToConnect(request: Request): Unit {
        match (this.request) {
            case Some(r) =>
                if (Util.sameConnection(r.getUrl(), request.getUrl()) && exchangeFinder.getOrThrow().hasRouteToTry()) {
                    return ()
                }
                if (hasExchange()) {
                    throw Exception()
                }
                if (hasExchangeFinder()) {
                    maybeReleaseConnection(true)
                    exchangeFinder = None
                }
            case None => ()
        }
        this.request = request
        address = createAddress(request.getUrl())
        this.exchangeFinder = Option<ExchangeFinder>.Some(ExchangeFinder(this, connectionPool, address, call))
    }

    private func createAddress(url: URL): Address {
        if (url.scheme == "https") {
            //TODO certificatePinner
        }
        return Address(url, client.getProtocols(), client.getTlsConfig())
    }

    /**
     * The Function is newExchange
     *
     * @param chain of Chain
     * @param doExtensiveHealthChecks of Bool
     *
     * @return Type of Exchange
     * @since 0.29.3
     */
     func newExchange(chain: Chain, doExtensiveHealthChecks: Bool): Exchange {
        let finder: ExchangeFinder = exchangeFinder.getOrThrow()
        let exchangeCodec: ExchangeCodec = finder.find(client, chain, doExtensiveHealthChecks)
        let result: Exchange = Exchange(this, call, finder, exchangeCodec)
        synchronized(connectionPool.mutex) {
            this.exchange = Some(result)
        }
        return result
    }

    public func noMoreExchanges() {
        synchronized (connectionPool.mutex) {
              noExchanges = true
        }
        maybeReleaseConnection(false)
    }

    private func maybeReleaseConnection(force: Bool) {
        var releasedConnection: Option<Connection>
        var socket: Option<Socket>
        synchronized (connectionPool.mutex) {
            if(force && hasExchange()) {
                throw HttpException("cannot release connection while it is in use")
            }
            releasedConnection = this.connection
            if (hasConnection() && !hasExchange() && (force || noExchanges)) {
                socket = releaseConnectionNoEvents()
            } else {
                socket = None
            }
            if(hasConnection()) {
                releasedConnection = None
            }
            Util.closeQuietly(socket)
        }
    }
    public func hasExchangeFinder() {
        return match (this.exchangeFinder) {
           case Some(conn) => true
           case None => false
       }
    }

    public func hasConnection(): Bool {
        synchronized (connectionPool.mutex){
            return match (this.connection) {
               case Some(conn) => true
               case None => false
           }
       }
    }

    public func hasExchange(): Bool {
        synchronized (connectionPool.mutex) {
            return match (exchange) {
               case Some(e) => return true
               case None => return false
           }
        }
    }

    func exchangeMessageDone(exchange: Exchange, requestDone: Bool, responseDone: Bool){
        var exchangeDone = false
        synchronized (connectionPool.mutex) {
            if (refEq(this.exchange.getOrThrow(), exchange)) {
                // from detached violently
                return
            }
            var changed = false
            if (requestDone) {
                if(!exchangeRequestDone) {
                    changed = true
                }
                this.exchangeRequestDone =true
            }
            if (responseDone) {
                if(!exchangeResponseDone) {
                    changed = true
                }
                this.exchangeResponseDone = true
            }
            if (exchangeRequestDone && exchangeResponseDone && changed) {
                exchangeDone = true
                this.exchange.getOrThrow().getConnection().successCount++
                this.exchange = None
            }
        }
        if (exchangeDone) {
            maybeReleaseConnection(false)
        }
    }

     public func exchangeDoneDueToException(): Unit {
        synchronized (connectionPool.mutex) {
          if (noExchanges) {
             throw HttpException("IllegalStateException");
          }
          exchange = None
        }
    }

    public func canRetry(): Bool {
        let ex = exchangeFinder.getOrThrow()
        return ex.getHasStreamFailure() && ex.hasRouteToTry()
    }
}