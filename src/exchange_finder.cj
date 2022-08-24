/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ExchangeFinder class.
 */
package okhttp


/**
 * The class is ExchangeFinder
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ExchangeFinder {
    /* var member transmitter type is Transmitter */
    private var transmitter: Transmitter
    /* var member address type is Address */
    private var address: Address
    /* var member call type is Call */
    private var call: Call
    /* var member connectionPool type is ConnectionPool */
    private var connectionPool: ConnectionPool
    /* var member routeSelector type is RouteSelector */
    private var routeSelector: RouteSelector
    /* var member connectingConnection type is Option<Connection> */
    private var connectingConnection:Option<Connection> = None
    private var hasStreamFailure: Bool = false
    private var nextRouteToTry: Option<Route> = None


    /**
     * The Function is init constructor
     *
     * @param transmitter of Transmitter
     * @param connectionPool of ConnectionPool
     * @param address of Address
     * @param call of Call
     * @since 0.29.3
     */
    public init (transmitter: Transmitter, connectionPool: ConnectionPool, address: Address, call: Call) {
        this.transmitter = transmitter
        this.connectionPool = connectionPool
        this.call = call
        this.address = address
        this.routeSelector = RouteSelector(address, connectionPool.routeDatabase)
    }

    /**
     * The Function is find
     *
     * @param client of OkHttpClient
     * @param chain of Chain
     * @param doExtensiveHealthChecks of Bool
     *
     * @return Type of ExchangeCodec
     * @since 0.29.3
     */
    public func find(client: OkHttpClient, chain: Chain, doExtensiveHealthChecks: Bool): ExchangeCodec {
        let connectTimeout: Option<Duration> = client.getConnectTimeout()
        let connectionRetryEnabled: Bool = client.getRetryOnConnectionFailure()
        let conn = findHealthyConnection(connectTimeout, connectionRetryEnabled)
        return conn.getOrThrow().newCodec(client, chain)
    }

    /*
     * The Function is findHealthyConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findHealthyConnection(connectTimeout:Option<Duration>, connectionRetryEnabled: Bool): Option<Connection> {
        while (true) {
            let candidate: Connection  =  findConnection(connectTimeout, connectionRetryEnabled)
            synchronized (connectionPool.mutex) {
                if (candidate.successCount == 0 && !candidate.isMultiplexed()) {
                  return candidate
                }
            }
            if(!candidate.isHealthy()) {
                candidate.noExchanges()
            }
            return candidate
        }
        return Option<Connection>.None
    }


    /*
     * The Function is findConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findConnection(connectTimeout:Option<Duration>, connectionRetryEnabled: Bool): Connection {
        let tuple: (Option<Socket>,Option<Connection>,Option<Route>) = firstGetConn();
        var toClose: Option<Socket> = tuple[0]
        var result: Option<Connection> = tuple[1]
        var selectedRoute: Option<Route> = tuple[2]
        Util.closeQuietly(toClose)
        match (result) {
            case Some(r) => return r
            case None => ()
        }
        let newRouteSelection: Bool = match (selectedRoute) {
            case Some(route) =>  false
            case None =>  true
        }
        synchronized (connectionPool.mutex) {
            if (transmitter.isCanceled()) {
                throw HttpException("Canceled")
            }
            if (newRouteSelection) {
                if (routeSelector.hasNext() && connectionPool.transmitterAcquirePooledConnection(
                    address, transmitter, routeSelector, requireMultiplexed: false)) {
                    result = transmitter.connection
                    return result.getOrThrow()
                }
            }
        }
        selectedRoute = routeSelector.next()
        result = Connection(connectionPool, selectedRoute.getOrThrow())
        connectingConnection = result
        var conn: Connection = result.getOrThrow()
        conn.connect(connectTimeout, connectionRetryEnabled)
        connectionPool.routeDatabase.connected(conn.route)
        var socket: Option<Socket> = None
        synchronized (connectionPool.mutex) {
            connectingConnection = None
            if (connectionPool.transmitterAcquirePooledConnection(
                                address, transmitter, routeSelector, requireMultiplexed: true)) {
                conn.noNewExchanges = true
                socket = conn.getSocket()
                conn = transmitter.connection.getOrThrow()
                nextRouteToTry = selectedRoute
            } else {
                connectionPool.put(conn)
                transmitter.acquireConnectionNoEvents(result)
            }
        }
        Util.closeQuietly(socket)
        return result.getOrThrow()
    }

    func firstGetConn(): (Option<Socket>,Option<Connection>,Option<Route>){
        var toClose: Option<Socket>
        var result: Option<Connection> = Option<Connection>.None
        var selectedRoute: Option<Route> = None
        synchronized (connectionPool.mutex) {
            if (transmitter.isCanceled()) {
                throw Exception("Transmitter has Canceled")
            }
            hasStreamFailure = false
            match(transmitter.connection) {
                case Some(conn) =>
                    result = transmitter.connection
                    if (conn.noNewExchanges) {
                        toClose = transmitter.releaseConnectionNoEvents()
                    } else {
                        toClose = Option<Socket>.None
                    }
                case _ =>
                    toClose = Option<Socket>.None
            }
            //Attempt to get a connection from the pool first time .
             match (result) {
                case Some(r) => ()
                case None =>
                    if (connectionPool.transmitterAcquirePooledConnection(address, transmitter, Option<RouteSelector>.None)){
                        result = transmitter.connection
                    } else {
                        match(nextRouteToTry) {
                            case Some(route) =>
                                selectedRoute = route
                                nextRouteToTry = None
                            case None =>
                                if (retryCurrentRoute()) {
                                    selectedRoute = transmitter.connection.getOrThrow().route
                                }
                        }
                    }
             }
        }
        return (toClose, result, selectedRoute)
    }

    func getHasStreamFailure(): Bool {
        synchronized (connectionPool.mutex) {
          return hasStreamFailure
        }
      }

    func hasRouteToTry(): Bool {
        synchronized(connectionPool.mutex) {
            match(nextRouteToTry) {
                case Some(route) => return true
                case None => ()
            }
            if (retryCurrentRoute()) {
                nextRouteToTry = transmitter.connection.getOrThrow().route
                return true
            }
        return routeSelector.hasNext()
        }
    }

    private func retryCurrentRoute(): Bool {
        match (transmitter.connection) {
            case Some(conn) =>
                if(conn.routeFailureCount == 0 &&
                    Util.sameConnection(conn.route.getAddress().getUrl(), address.getUrl())) {
                    return true
                } else {
                    return false
                }
            case None => return false
        }
    }
}

/**
 * The class is Exchange
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Exchange {

    /** var member transmitter type is Transmitter */
    public var transmitter: Transmitter
    /** var member call type is Call */
    public var call: Call
    /** var member finder type is ExchangeFinder */
    public var finder: ExchangeFinder
    /** var member codec type is ExchangeCodec */
    public var codec: ExchangeCodec

    /**
     * The Function is init constructor
     *
     * @param transmitter of Transmitter
     * @param call of Call
     * @param finder of ExchangeFinder
     * @param codec of ExchangeCodec
     * @since 0.29.3
     */
    public init (transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec) {
        this.transmitter = transmitter
        this.call = call
        this.finder = finder
        this.codec = codec
    }

    /**
     * The Function is write
     *
     * @param request of Request
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func write(request: Request): Unit {
        codec.write(request)
    }

    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    public func readResponseHeaders(): ResponseBuilder {
        return codec.readResponseHeaders()
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of ResponseBody
     * @since 0.29.3
     */
    public func openResponseBody(): Option<ResponseBody>{
         return codec.openResponseBody()
    }

    public func getConnection(): Connection {
        return codec.getConnection()
    }

    public func cancel() {
        codec.cancel()
    }

    public func detachWithViolence() {
        cancel()
        transmitter.exchangeMessageDone(this, true, true)
    }

    public func noNewExchangesOnConnection(): Unit {
        codec.getConnection().noExchanges()
    }

}