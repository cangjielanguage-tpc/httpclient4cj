/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Connection class.
 */
package okhttp

from http2 import proto.*

/**
 * The class is Connection
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Connection {
    /* var member connectionPool type is ConnectionPool */
    private let connectionPool: ConnectionPool
    /* var member transmitters type is ArrayList<Transmitter> */
    var transmitters: ArrayList<Transmitter> = ArrayList<Transmitter>()
    /* var member socket type is Option<Socket> */
    var socket: Option<Socket> = Option<Socket>.None
    /* var member route type is Route */
    let route: Route
    /*If true, no new exchanges can be created on this connection.*/
    var noNewExchanges: Bool = false

    private var allocationLimit: Int64 = 1

    private var protocol: Protocol = HTTP_1_1

    private var h2conn: Option<H2ClientConn> = None

    var idleAtNanos: Time = Time(0, 0x7fffffffffffffff)

    var successCount: Int64 = 0

    var routeFailureCount: Int64 = 0

    /**
     * The Function is init constructor
     *
     * @param connectionPool of ConnectionPool
     * @param route of Route
     * @since 0.29.3
     */
    public init(connectionPool: ConnectionPool, route: Route) {
        this.connectionPool = connectionPool
        this.route = route
    }

    /**
     * The Function is getProtocol
     *
     * @return Type of Protocol
     * @since 0.30.4
     */
    public func getProtocol(): Protocol {
        return protocol
    }

    /**
     * The Function is getTransmitters
     *
     * @return Type of ArrayList<Transmitter>
     * @since 0.29.3
     */
    public func getTransmitters(): ArrayList<Transmitter> {
        return transmitters
    }

    /**
     * The Function is noExchanges
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func noExchanges(): Unit {
        synchronized(connectionPool.mutex) {
            noNewExchanges = true
        }
    }

    /**
     * The Function is getSocket
     *
     * @return Type of Option<Socket>
     * @since 0.29.3
     */
    public func getSocket(): Option<Socket>{
        return socket
    }
    /**
     * The Function is getRoute
     *
     * @return Type of Route
     * @since 0.29.3
     */
    public func getRoute(): Route {
        return route
    }

    /**
     * The Function is isEligible
     *
     * @param address of Address
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func isEligible(address: Address, routeSelector: Option<RouteSelector>): Bool {
        if (transmitters.size() >= allocationLimit || noNewExchanges) {
            return false
        }

        if (this.route.getAddress() != address) {
            return false
        }

        if (address.getUrl().host == route.getAddress().getUrl().host) {
            return true
        }
        // HTTP/2.
        match(h2conn) {
            case Some(conn) => ()
            case None => return false
        }
        //any same address
        match (routeSelector) {
            case Some(rs) =>
                if(!routeMatchesAny(rs)) {
                    return false
                }
                ()
            case None => return false
        }
        return true
    }

    public func isHealthy(): Bool {
        if(socket.getOrThrow().isClosed()) {
            return false
        }
        match (h2conn) {
            case Some(h2con) =>
                return h2con.connState.value() == 0x3
            case None => ()
        }
        return true
    }

    private func routeMatchesAny(routeSelector: RouteSelector): Bool {
        for (select in routeSelector.getAll()) {
            if(route.inetSocketAddress == select.inetSocketAddress) {
                return true
            }
        }
        return false
    }

    /**
     * The Function is isMultiplexed
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func isMultiplexed(): Bool {
        match (h2conn) {
            case Some(v) => return true
            case None => return false
        }
    }

    /**
     * The Function is connect
     *
     * @since 0.29.3
     */
    public func connect(connectTimeout: Option<Duration>, connectionRetryEnabled: Bool) {
        while (true) {
            try {
                connectSocket(connectTimeout)
                establishProtocol()
                break
            } catch(e : ConnectException) {
                Util.closeQuietly(socket)
                socket = None
                h2conn = None
                if (!connectionRetryEnabled || !connectionFailed(e)) {
                    throw RouteException("${e.getMessage()}", e)
                }
            }

        }
        match(h2conn) {
            case Some(h2) =>
               synchronized (connectionPool.mutex) {
                  allocationLimit = Int64(Int32.Max)
               }
            case None => ()
        }
    }

    func connectionFailed(e: ConnectException): Bool {
        match (e.contain) {
            case timeout: SocketTimeoutException => return false
            case _ => return e is TlsException
        }
    }

    /*
     * The Function is connectSocket
     *
     * @since 0.29.3
     */
    private func connectSocket(connectTimeout: Option<Duration>) {
        let socketAddress: SocketAddress =  route.inetSocketAddress
        try {
            let s = Socket(TCP, socketAddress.hostAddress, socketAddress.port)
            match (connectTimeout) {
                case Some(time) => s.connect(time)
                case None => s.connect()
            }
            socket = Some(s)
        } catch (e: SocketException){
            throw ConnectException("Failed to connect to ${socketAddress}", e)
        } catch (e1: SocketTimeoutException){
            throw ConnectException("connect to ${socketAddress} time out", e1)
        } catch (e2: TlsException) {
            throw ConnectException("{e2.getMessage()}", e2)
        }
    }

    private func establishProtocol() {
        //TODO TLS
        if (route.getAddress().getProtocols().contains(Protocol.H2_PRIOR_KNOWLEDGE.toString())) {
            this.protocol = H2_PRIOR_KNOWLEDGE
            startHttp2()
        }
        if (route.getAddress().getProtocols().contains(Protocol.HTTP_2.toString())) {
            this.protocol = HTTP_2
            startHttp2()
        }
    }

    private func startHttp2() {
        match (socket) {
            case Some(s) => h2conn = H2ClientConn.createClientConn(H2Transport(), s)
            case None => ()
        }
    }


    /**
     * The Function is newCodec
     *
     * @param client of OkHttpClient
     * @param chain of Chain
     *
     * @return Type of ExchangeCodec
     * @since 0.29.3
     */
    func newCodec(client: OkHttpClient, chain: Chain): ExchangeCodec {
        match (h2conn) {
            case None => Http1ExchangeCodec(client, this,  client.getReadTimeout(), client.getWriteTimeout())
            case Some(conn) => Http2ExchangeCodec(this, conn)
        }
    }

    /**
     * The Function is cancel
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func cancel(): Unit {
        Util.closeQuietly(socket)
    }
}
