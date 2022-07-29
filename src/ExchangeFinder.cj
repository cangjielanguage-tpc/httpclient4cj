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
        this.routeSelector = RouteSelector(address, call)
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
        let writeTimeout: Option<Duration> =  client.getWriteTimeout()
        let conn: Connection = findHealthyConnection(connectTimeout)
        return conn.newCodec(client, chain)
    }

    /*
     * The Function is findHealthyConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findHealthyConnection(connectTimeout:Option<Duration>): Connection {
        let candidate: Connection  =  findConnection(connectTimeout)
        return candidate

    }


    /*
     * The Function is findConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findConnection(connectTimeout:Option<Duration>): Connection {
        // TODO Connection reuse
        var toClose: Option<Socket>
        var result: Option<Connection> = Option<Connection>.None
        synchronized (connectionPool.mutex) {
            if (transmitter.isCanceled()) {
                throw Exception("Transmitter has Canceled")
            }
            match(transmitter.connection) {
                case Some(conn) =>
                    toClose = transmitter.releaseConnectionNoEvents()
                    result = transmitter.connection
                case _ =>
                    toClose = Option<Socket>.None
                    // Attempt to get a connection from the pool.
                    // TODO route
                    if (connectionPool.transmitterAcquirePooledConnection(address,transmitter)){
                        result = transmitter.connection
                    }
            }
        }
        Util.closeQuietly(toClose)
        let ret: Connection = match (result) {
            case Some(r) =>
                transmitter.acquireConnectionNoEvents(r)
                return  r
            case None =>
                let conn = Connection(connectionPool, routeSelector.next())
                conn.connect(connectTimeout)
                transmitter.acquireConnectionNoEvents(conn)
                connectingConnection = Option<Connection>.Some(conn)
                return conn
        }
        return ret
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
}