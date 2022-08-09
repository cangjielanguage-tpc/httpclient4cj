/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Connection class.
 */
package okhttp

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
    var cleanupRunning: Bool = false
    private let keepAliveDurationNs: Duration

    /**
     * The Function is init constructor
     *
     * @param maxIdleConnections of Int64
     * @since 0.29.3
     */
    public init(maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute(5)) {
        this.maxIdleConnections = maxIdleConnections
        this.keepAliveDurationNs = keepAliveDurationNs
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
        let conn = connection
        if (connection.noNewExchanges || maxIdleConnections == 0) {
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
            }
            return true
        } else {
            // Awake the cleanup thread
            mutex.notifyAll()
            return false
        }
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

    func put(connection: Connection) {
        if(!cleanupRunning) {
            cleanupRunning = true
            spawnCleanup()
        }
        connections.add(connection)
    }

    func spawnCleanup() {
        spawn {
           while (true) {
                let waitNanos = cleanup()
                if (waitNanos == -1) {
                    return
                }
                synchronized (mutex) {
                    if (waitNanos > 0) {
                        this.mutex.wait(timeout: UInt64(waitNanos))
                    }
                }
            }
        }
    }

    func cleanup(): Int64{
        var longestIdleDurationNs: Duration = Duration.nanosecond(0x7fffffffffffffff)
        var idleConnectionCount = 0
        var longestIdleConnection: Option<Connection> = None
        synchronized (this.mutex) {
            let it = connections.iterator()
            var index = 0
            while(true) {
                match (it.next()) {
                    case Some(conn) =>
                        let idleDurationNs: Duration = Time.now() - conn.idleAtNanos
                        if (idleDurationNs > longestIdleDurationNs) {
                            longestIdleDurationNs = idleDurationNs
                            longestIdleConnection = conn
                        }
                        // weather the connection is ready to be evicted
                        if (longestIdleDurationNs >= keepAliveDurationNs ||
                            idleConnectionCount > this.maxIdleConnections) {
                            connections.remove(index);
                        } else if (idleConnectionCount > 0) {
                             // wait for next time
                             return (keepAliveDurationNs - longestIdleDurationNs).nanoseconds()
                        } else {
                            cleanupRunning = false
                            return -1
                        }
                    case None => break
                }
                index++;
            }
        }
        match (longestIdleConnection) {
            case Some(conn) =>
                Util.closeQuietly(conn.getSocket())
                ()
            case None => ()
        }
        return 0
    }
}
