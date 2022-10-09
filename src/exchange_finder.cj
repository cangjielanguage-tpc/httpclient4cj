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
class ExchangeFinder {
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
    private var connectingConnection: Option<Connection> = None
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
    init (transmitter: Transmitter, connectionPool: ConnectionPool, address: Address, call: Call) {
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
        let readTimeout: Option<Duration> = client.getReadTimeout()
        let writeTimeout: Option<Duration> = client.getWriteTimeout()
        let connectionRetryEnabled: Bool = client.getRetryOnConnectionFailure()
        try {
            let conn = findHealthyConnection(connectTimeout, readTimeout, writeTimeout, connectionRetryEnabled)
            return conn.getOrThrow().newCodec(client, chain)
        } catch (e: RouteException) {
            trackFailure()
            throw e
        } catch(e1: ConnectException) {
            trackFailure()
            throw RouteException(e1.message, e1)
        }
    }

    /*
     * The Function is findHealthyConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findHealthyConnection(connectTimeout: Option<Duration>, readTimeout: Option<Duration>,
        writeTimeout: Option<Duration>, connectionRetryEnabled: Bool): Option<Connection> {
        while (true) {
            let candidate: Connection  =  findConnection(connectTimeout, readTimeout,
                writeTimeout, connectionRetryEnabled)
            synchronized (connectionPool.mutex) {
                if (candidate.successCount == 0 && !candidate.isMultiplexed()) {
                  return candidate
                }
            }
            if (!candidate.isHealthy()) {
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
    private func findConnection(connectTimeout:Option<Duration>, readTimeout: Option<Duration>,
        writeTimeout: Option<Duration>, connectionRetryEnabled: Bool): Connection {
        let tuple: (Option<OKSocket>,Option<Connection>,Option<Route>) = firstGetConn();
        var toClose: Option<OKSocket> = tuple[0]
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
        conn.connect(connectTimeout, readTimeout, writeTimeout, connectionRetryEnabled)
        connectionPool.routeDatabase.connected(conn.route)
        var socket: Option<OKSocket> = None
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

    func firstGetConn(): (Option<OKSocket>,Option<Connection>,Option<Route>) {
        var toClose: Option<OKSocket>
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
                        toClose = Option<OKSocket>.None
                    }
                case _ =>
                    toClose = Option<OKSocket>.None
            }
            //Attempt to get a connection from the pool first time .
             match (result) {
                case Some(r) => ()
                case None =>
                    if (connectionPool.transmitterAcquirePooledConnection(address,
                            transmitter, Option<RouteSelector>.None)) {
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

    func getConnectingConnection(): Option<Connection>  {
        return connectingConnection
    }

    func hasRouteToTry(): Bool {
        synchronized (connectionPool.mutex) {
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
                if (conn.routeFailureCount == 0 &&
                    Util.sameConnection(conn.route.getAddress().getUrl(), address.getUrl())) {
                    return true
                } else {
                    return false
                }
            case None => return false
        }
    }
    func trackFailure(): Unit {
       synchronized (connectionPool.mutex) {
             hasStreamFailure = true
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
    let transmitter: Transmitter
    /** var member call type is Call */
    let call: Call
    /** var member finder type is ExchangeFinder */
    let finder: ExchangeFinder
    /** var member codec type is ExchangeCodec */
    let codec: ExchangeCodec

    /**
     * The Function is init constructor
     *
     * @param transmitter of Transmitter
     * @param call of Call
     * @param finder of ExchangeFinder
     * @param codec of ExchangeCodec
     * @since 0.29.3
     */
     init (transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec) {
        this.transmitter = transmitter
        this.call = call
        this.finder = finder
        this.codec = codec
    }

    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder> {
        let result: Option<ResponseBuilder> = codec.readResponseHeaders(expectContinue)
        match (result) {
            case Some(r) => initExchange(r, this)
            case None => ()
        }
        return result
    }

    private func initExchange(respb: ResponseBuilder, exchange: Exchange): Unit {
         respb.initExchange(exchange)
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of ResponseBody
     * @since 0.29.3
     */
    public func openResponseBody(response: Response): ResponseBody{
         let contentType: String = response.getHeader("Content-Type","")
         let contentLength: Int64 = codec.reportedContentLength(response)
         let source = codec.openResponseBodySource(response)
         return ResponseBody(contentType, contentLength, ResponseBodySource(source, this, contentLength))
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

    public func noRequestBody(): Unit {
        transmitter.exchangeMessageDone(this, true, false);
    }

    public func createRequestBody(request: Request): Sink{
        let contentLength = request.getBody().getOrThrow().getContentLength()
        let rawRequestBody: Sink = codec.createRequestBody(request)
        return RequestBodySink(rawRequestBody, contentLength, this)
    }

    public func writeRequestHeaders(request: Request): Unit {
        try {
            codec.writeRequestHeaders(request)
        } catch (e: IOException) {
             throw e
        }
    }

    public func flushRequest(): Unit {
        codec.flushRequest()
    }

    public func finishRequest(): Unit {
        codec.finishRequest()
    }

    func bodyComplete(responseDone: Bool, requestDone: Bool, exception: Option<NetException>): Unit{
        match(exception) {
            case Some(e) => trackFailure(e)
            case None => ()
        }
        transmitter.exchangeMessageDone(this, requestDone, responseDone)
    }

    func trackFailure(exception: NetException): Unit{
        finder.trackFailure()
        codec.getConnection().trackFailure(exception)
    }
}