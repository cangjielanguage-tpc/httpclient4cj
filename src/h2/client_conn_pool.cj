/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file manage http/2 client connection pools.
 */

package h2

from net import tls.*
from net import http.*
from std import socket.*
from std import sync.*

public class ClientConnPool {

    protected var h2t: H2Transport
    protected let monitor: Monitor = Monitor()

    /* After the connection in value is obtained, the connection is not removed from the LinkedList and still exists? */
    /* key is host:port */
    protected var conns: HashMap<String, LinkedList<H2ClientConn>> = HashMap<String, LinkedList<H2ClientConn>>()
    /* Dialing in flight */
    protected var dialing: HashMap<String, DialCall> = HashMap<String, DialCall>()

    /* HashMap<H2ClientConn, ArrayList<String>> */
    protected var keys: SyncClientConnKey = SyncClientConnKey()

    protected let dialOnMiss: Bool = true
    protected let noDialOnMiss: Bool = false

    public init() {
        this.h2t = H2Transport()
    }

    public init(h2t: H2Transport) {
        this.h2t = h2t
    }

    /**
     * Returns a specific http/2 connection (usually a tls-tcp connection) to an http/2 server.
     * When successful, the returned clientconn will explain the upcoming round trip call, so the caller should not ignore it.
     * If the caller needs to, he can use pseudo new (http.request) to call the clientconn round trip to release the stream reservation.
     *
     * @param req of H2Request
     * @param addr of String
     *
     * @return Type of H2ClientConn
     * @return Type of String
     * @since 0.30.4
     */
    public func getClientConn(req: H2Request, addr: String): (H2ClientConn, String) {
        return getClientConn(req, addr, dialOnMiss)
    }

    protected func getClientConn(req: H2Request, addr: String, dialOnMiss: Bool): (H2ClientConn, String) {
        /* When h2t.disablekeepalives is set, dial new connection? */
        if (isConnectionCloseRequest(req) && dialOnMiss) {
            /* get a new conn */
            let singleUse: Bool = true
            let cc: H2ClientConn = h2t.dialClientConn(req, addr, singleUse)
            return (cc, "")
        }

        while (true) {
            let arr: LinkedList<H2ClientConn> = match (this.conns.get(addr)) {
                case Some(v) => v
                case None => LinkedList<H2ClientConn>()
            }
            for (cc in arr) {
                /* Monitor whether the connections in the connection pool are available. */
                if (cc.reserveNewRequest()) {
                    return (cc, "")
                }
            }

            if (!dialOnMiss) {
                throw Http2Exception("error no cached connection.")
            }

            /* Generate new conn */
            let call: DialCall = getStartDialLocked(req, addr)

            /* Whether the current request should retry dialing after the call is not successfully completed. */
            if (call.shouldRetryDial()) {
                continue
            }
            let cc: H2ClientConn = match (call.h2conn) {
                case Some(v) => v
                case None => throw Http2Exception("conn in call is empty.")
            }

            if (cc.reserveNewRequest()) {
                return (cc, "")
            }
        }
        if (req.host.contains("https")) {
            var cfg = TlsClientConfig("")
            cfg.verifyMode = VerifyNone
            return (H2ClientConn.createClientConn(H2Transport(), TlsSocket(TCP, "127.0.0.1", 0, cfg)), "")
        } else {
            return (H2ClientConn.createClientConn(H2Transport(), Socket(TCP, "0.0.0.0", 0)), "")
        }

    }

    protected func getStartDialLocked(req: H2Request, addr: String): DialCall {
        match (this.dialing.get(addr)) {
            case Some(v) => return v
            case None => ()
        }
        var call: DialCall = DialCall(this)
        this.dialing.put(addr, call)
        call.dial(req, addr)
        return call
    }

    protected func addConnLocked(key: String, cc: H2ClientConn): Unit {
        var connsValue: LinkedList<H2ClientConn> = LinkedList<H2ClientConn>()
        match (this.conns.get(key)) {
            case Some(v) => connsValue = v
            case None => ()
        }
        for (conn in connsValue) {
            /* Check whether the address is the same => refEq(conn, cc) */
            if (refEq(conn, cc)) { return }
        }
        match (this.conns.get(key)) {
            case Some(v) => v.append(cc)
            case None =>
                var ll: LinkedList<H2ClientConn> = LinkedList<H2ClientConn>()
                ll.append(cc)
                this.conns.put(key, ll)
                ()
        }
        this.keys.add(cc, key)
    }

    /**
     * Mark and clear CC
     *
     * @param cc of H2ClientConn, h2clientconn object that needs to be marked and cleared.
     *
     * @since 0.30.4
     */
    public func markDead(cc: H2ClientConn): Unit {
        synchronized(monitor) {
            var arr: ArrayList<String> = this.keys.get(cc)
            for (key in arr) {
                let vv: LinkedList<H2ClientConn> = match (this.conns.get(key)) {
                    case Some(v) => v
                    case None => LinkedList<H2ClientConn>()
                }
                let newList: LinkedList<H2ClientConn> = filterOutClientConn(vv, cc)
                if (newList.size > 0) {
                    this.conns.put(key, newList)
                } else {
                    this.conns.remove(key)
                }
            }
            this.keys.delete(cc)
        }
    }

    protected func filterOutClientConn(arrh2C: LinkedList<H2ClientConn>, exclude: H2ClientConn): LinkedList<H2ClientConn> {
        var out: LinkedList<H2ClientConn> = LinkedList<H2ClientConn>()
        for (v in arrh2C) {
            if (!refEq(v, exclude)) {
                out.append(v)
            }
        }
        /* If we filter it out, zero the last item to prevent the GC from seeing it. */
        if (arrh2C.size != out.size) {
            arrh2C.remove(arrh2C.size - 1)
        }
        return out
    }

    public func size(): Int64 {
        return this.conns.size
    }
}

public class DialCall {

    protected var pool: ClientConnPool
    protected var h2conn: ?H2ClientConn = None
    /* Valid after completion */
    protected var err: String = ""

    protected init(pool: ClientConnPool) {
        this.pool = pool
    }

    /* Run in your own func. */
    protected func dial(req: H2Request, addr: String): Unit {
        let singleUse: Bool = false
        try {
            let conn: H2ClientConn = this.pool.h2t.dialClientConn(req, addr, singleUse)
            this.h2conn = Some(conn)
            synchronized(this.pool.monitor) {
                this.pool.dialing.remove(addr)
                this.pool.addConnLocked(addr, conn)
            }
        } catch(e: Exception) {
            this.err = e.toString()
        }
    }

    /* Whether the current request should retry dialing after the call is not successfully completed. */
    protected func shouldRetryDial(): Bool {
        if (this.err.isEmpty()) {
            return false
        }

        match (this.h2conn) {
            case Some(v) => return v.hts.idleTimeout != Duration.nanosecond(0) && this.err.contains("idle time out")
            case None => ()
        }
        return false
    }
}

public class SyncClientConnKey {
    private var myData: ArrayList<H2ClientConn> = ArrayList<H2ClientConn>(32)
    private let m: Monitor = Monitor()
    private var num: Int64 = 0

    /*
     * HashMap<H2ClientConn, ArrayList<String>>
     *
     * HashMap<Int64, ArrayList<String>> + HashMap<Int64, H2ClientConn> + ArrayList<H2ClientConn>
     * HashMap<Int64, H2ClientConn> -- key: Self increasing value as key; value: H2ClientConn
     * HashMap<Int64, ArrayList<String>> -- key: key corresponding to H2ClientConn; value:
     * ArrayList<H2ClientConn> -- H2ClientConn with the same address needs to cover the original
     */
    protected var keysK: HashMap<Int64, H2ClientConn> = HashMap<Int64, H2ClientConn>()
    protected var keysV: HashMap<Int64, ArrayList<String>> = HashMap<Int64, ArrayList<String>>()

    let EMPTY_ALS: ArrayList<String> = ArrayList<String>()

    protected init() {}

    protected func size(): Int64 {
        synchronized(m) {
            return this.myData.size
        }
    }

    protected func add(cc: H2ClientConn, keyConns: String): Unit {
        synchronized(m) {
            let (indexMyData, index): (Int64, Int64) = getKeysKIndex(cc)
            if (index != -1) {
                var arr: ArrayList<String> = this.keysV[index]
                if (!arr.contains(keyConns)) {
                    arr.append(keyConns)
                }
                return
            }
            this.myData.append(cc)
            this.keysK.put(num, cc)
            this.keysV.put(num, ArrayList<String>([keyConns]))
            num++
        }
    }

    protected func containsConn(cc: H2ClientConn): Int64 {
        var index: Int64 = -1
        for (conn in this.myData) {
            index++
            if (refEq(conn, cc)) { return index }
        }
        return -1
    }

    /*(Int64, Int64) => (uubscript in mydata, key value in keysk) */
    protected func getKeysKIndex(cc: H2ClientConn): (Int64, Int64) {
        var index: Int64 = -1
        let indexMyData: Int64 = containsConn(cc)
        if (indexMyData == -1) { return (-1, -1) }
        for ((k, v) in this.keysK) {
            if (refEq(v, cc)) {
                index = k
                break
            }
        }
        /* Cc: if h2clientconn is in mydata but not in keysk, close the CC and remove it from mydata */
        if (index == -1) {
            cc.socket.close()
            cc.closed.store(true)
            this.myData.remove(indexMyData)
            return (-1, -1)
        }
        return (indexMyData, index)
    }

    protected func get(cc: H2ClientConn): ArrayList<String> {
        synchronized(m) {
            let (indexMyData, index): (Int64, Int64) = getKeysKIndex(cc)
            if (index == -1) { return EMPTY_ALS }
            return this.keysV[index]
        }
    }

    protected func delete(cc: H2ClientConn): Unit {
        synchronized(m) {
            let (indexMyData, index): (Int64, Int64) = getKeysKIndex(cc)
            if (index == -1) { return }
            this.myData.remove(indexMyData)
            this.keysK.remove(index)
            this.keysV.remove(index)
        }
    }

}