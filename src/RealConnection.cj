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
    public var noNewExchanges: Bool = false

    private var allocationLimit: Int64 = 1

    private var protocol: Protocol = HTTP_1_1

    private var h2conn: Option<H2ClientConn> = None

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
        match(parseUInt16(url.port())){
            case Some(v) => port = v
            case None =>
                if (url.toString().startsWith("https")) {
                    port = 443
                } else {
                    port = 80
                }
        }
        let s = Socket(TCP, url.hostname(), port)

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


/**
 * The class is ConnectionPool
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ConnectionPool {
    /* var member connections type is ConcurrentQueue<Connection> */
    private var connections: ConcurrentQueue<Connection> = ConcurrentQueue()
    /** var member mutex type is Monitor */
    public  var mutex: Monitor = Monitor()
    /** var member maxIdleConnections type is Int64 */
    public  var maxIdleConnections: Int64

    /**
     * The Function is init constructor
     *
     * @param maxIdleConnections of Int64
     * @since 0.29.3
     */
    public init(maxIdleConnections: Int64) {
        this.maxIdleConnections = maxIdleConnections
    }


    /*
     * The Function is connectionBecameIdle
     *
     * @param connection of Connection
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func connectionBecameIdle(connection: Connection): Bool {
        let conn =  connection
        if (maxIdleConnections == 0) {
            var index = -1
            var removeIndex = -1
            for (i in connections) {
               index++
               if (refEq(i,conn) ) {
                   removeIndex = index
                   break
               }
            }
            if(removeIndex != -1) {
                connections.remove(removeIndex)
                return true
            }
        }
        return false
    }

    /*
     * The Function is transmitterAcquirePooledConnection
     *
     * @param address of Address
     * @param transmitter of Transmitter
     * @param requireMultiplexed of Bool, and the Default value is false
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func transmitterAcquirePooledConnection(address: Address,transmitter: Transmitter, requireMultiplexed!: Bool = false): Bool {
        for (conn in connections) {
             if (requireMultiplexed && !conn.isMultiplexed()) {
                continue
             }
             if(!conn.isEligible(address)) {
                continue
             }
             transmitter.acquireConnectionNoEvents(conn)
             return true
        }
        return false
    }

    /**
     * The Function is connectionCount
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func connectionCount(): Int64 {
        synchronized(mutex) {
            return connections.size()
        }
    }

    /**
     * The Function is idleConnectionCount
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func idleConnectionCount(): Int64 {
        var total = 0
        for (connection in connections) {
            if(connection.getTransmitters().size() == 0) {
                total++
            }
        }
        return total
    }

    /**
     * The Function is evictAll
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func evictAll(): Unit {
        let evictedConnections: ArrayList<Connection> = ArrayList<Connection>()
        synchronized(mutex) {
            connections.removeIf(
                { connection: Connection =>
                    if (connection.getTransmitters().size() == 0) {
                         connection.noNewExchanges = true
                         evictedConnections.append(connection)
                         return true
                    }
                    return false
                }
            )
        }
        for(connection in evictedConnections) {
            Util.closeQuietly(connection.getSocket())
        }
    }
}
