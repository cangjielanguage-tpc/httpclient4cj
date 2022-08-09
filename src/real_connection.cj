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
    private var connectionPool: ConnectionPool
    /* var member transmitters type is ArrayList<Transmitter> */
    var transmitters: ArrayList<Transmitter> = ArrayList<Transmitter>()
    /* var member socket type is Option<Socket> */
    var socket: Option<Socket> = Option<Socket>.None
    /* var member route type is Route */
    var route: Route
    /*If true, no new exchanges can be created on this connection.*/
    var noNewExchanges: Bool = false

    private var allocationLimit: Int64 = 1

    private var protocol: Protocol = HTTP_1_1

    private var h2conn: Option<H2ClientConn> = None

    var idleAtNanos: Time = Time(0, 0x7fffffffffffffff)

    var successCount: Int64 = 0

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
    public func getRoute(): Route{
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
    public func isEligible(address: Address): Bool {
        if (transmitters.size() >= allocationLimit || noNewExchanges) {
            return false
        }

        if (address.getUrl().host == route.getAddress().getUrl().host) {
            return true
        }

        return false
    }

    /**
     * The Function is isMultiplexed
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func isMultiplexed(): Bool{
        // TODO
        return false
    }

    /**
     * The Function is connect
     *
     * @since 0.29.3
     */
    public func connect(connectTimeout: Option<Duration>) {
        connectSocket(connectTimeout)
        establishProtocol()
    }

    /*
     * The Function is connectSocket
     *
     * @since 0.29.3
     */
    private func connectSocket(connectTimeout: Option<Duration>) {
        var port:UInt16 = 80
        var url = route.getAddress().getUrl()
        var host = url.hostname()
        match(parseUInt16(url.port())){
            case Some(v) => port = v
            case None =>
                if (url.toString().startsWith("https")) {
                    port = 443
                } else {
                    port = 80
                }
        }

        if(host.contains(":")) {
            host =host.substring(0,host.indexOf(':').getOrThrow())
        }
        let s = Socket(TCP, host, port)
        match (connectTimeout) {
            case Some(time) => s.connect(time)
            case None => s.connect()
        }
        socket = Some(s)
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
    public func newCodec(client: OkHttpClient, chain: Chain): ExchangeCodec {
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
