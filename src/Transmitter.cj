/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Transmitter class.
 */
package okhttp

from std import sync.*

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
    private var address: Address = Address(URL.parse(""), ArrayList<String>(), Option<TlsConfig>.None)
    /* var member exchangeFinder type is Option<ExchangeFinder> */
    private var exchangeFinder: Option<ExchangeFinder> = None
    /* var member exchange type is Option<Exchange> */
    private var exchange: Option<Exchange> = None

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @param call of Call
     * @since 0.29.3
     */
    public init (client: OkHttpClient, call: Call) {
        this.client = client
        this.connectionPool = client.getConnectionPool() ?? ConnectionPool(0)
        this.call = call
    }

    /**
     * The Function is cancel
     *
     * @since 0.29.3
     */
    public func cancel() {
        canceled = true
    }

    /**
     * The Function is isCanceled
     *
     * @since 0.29.3
     */
    public func isCanceled() {
        return canceled
    }

    /**
     * The Function is releaseConnectionNoEvents
     *
     * @return Type of Option<Socket>
     * @since 0.29.3
     */
    public func releaseConnectionNoEvents(): Option<Socket> {
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
    public func acquireConnectionNoEvents(connection: Connection): Unit {
        synchronized (connectionPool.mutex) {
            this.connection =  Option<Connection>.Some(connection)
            connection.transmitters.append(this)
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
        var isRequest: Bool = false
        match (this.request) {
            case Some(r) =>
                if (Util.sameConnection(r.getUrl(), request.getUrl())) {
                    return ()
                }
                isRequest = true
            case None => ()
        }
        if (isRequest) {
            // TODO

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
    public func newExchange(chain: Chain, doExtensiveHealthChecks: Bool): Exchange {
        let finder: ExchangeFinder = exchangeFinder.getOrThrow()
        let exchangeCodec: ExchangeCodec = finder.find(client, chain, doExtensiveHealthChecks)
        let result: Exchange = Exchange(this, call, finder, exchangeCodec)
        synchronized(connectionPool.mutex) {
            this.exchange = Some(result)
        }
        return result
    }
}

