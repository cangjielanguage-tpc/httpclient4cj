/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */
/**
 * @file The file declars the xxxx class.
 */

package h2

from std import convert.*
from std import time.*
from std import io.*
from encoding import url.*
from net import http.* as h1.*

//import okhttp.*

public open class H2Transport{
    protected var disableCompression: Bool = true
    protected var allowHTTP: Bool = true
    protected var maxHeaderListSize: UInt32 = 65535
    protected var strictMaxConcurrentStreams: Bool = false
    protected var readIdleTimeout: Duration = Duration.nanosecond(0)
    protected var pingTimeout : Duration = Duration.nanosecond(0)
    protected var writeByteTimeout : Duration = Duration.nanosecond(0)
    protected var ReadIdleTimeout : Duration = Duration.nanosecond(0)
    protected var idleTimeout: Duration = Duration.second()
    protected var countError: ()->String = { => ""}
    private   let mu: ReentrantMutex = ReentrantMutex()

    /*
     * Specify the TLS configuration to use with TLS clients.
     * If zero, the default configuration is used.
     */
    protected var tlsClientCfg: Option<TlsClientConfig> = None

    /*
     * You can optionally specify an alternate connection pool to use.
     * If it is zero, the default value is used.
     */
    protected var connPool: ?ClientConnPool = None
    protected var hasConnPoolOnce: AtomicBool = AtomicBool(false)
    public prop var connPoolOnce: Bool {
        get() { return this.hasConnPoolOnce.load() }
        set(value) { this.hasConnPoolOnce.store(value) }
    }

    protected func handleConnPool(): Unit {
        if (this.connPoolOnce) {
            return
        }
        this.connPool = Some(ClientConnPool(this))
        this.connPoolOnce = true
    }

    public func getDisableCompression(): Bool {
        return this.disableCompression
    }

    public func roundTrip(h1req: h1.Request): H1Response{
        let req = H2Request(h1req)
        var reqss = req.body as ByteArrayStream
        var scheme = req.url.scheme
        var isHTTP: Bool = scheme == "http" || scheme == "https"
        if (isHTTP) {
            try {
                req.header.checkHeaderNameVal()
            } catch(e: Exception) {
                return H1Response()
            }
        }
        if (!isHTTP) {
            throw h1.HttpException("unsupported protocol scheme ${scheme}")
        }
        if (req.url.host == "") {
            throw h1.HttpException("http: no Host in request URL")
        }
        return this.createClient(req).getOrThrow().doRequest(req).resp
    }

    protected func createClient(request: H2Request): Option<H2ClientConn> {
        var host: String = request.url.hostname()
        let port: UInt16 = match(UInt16.tryParse(request.url.port())){
            case Some(v) => v
            case None =>
                if (request.url.toString().startsWith("https")) {
                    443
                } else {
                    80
                }
        }
        this.handleConnPool()
        let addr: String = authorityAddr(request.url.scheme, request.url.host)

        let (h2conn, err): (H2ClientConn, String) = match (this.connPool) {
            case Some(v) => v.getClientConn(request, addr)
            case None => throw Http2Exception("the client conn pool is null.")
        }
        if (!err.isEmpty()){
            return None
        }
        return Some(h2conn)
    }

    /* Createsocket is in the dorequest function of the client */
    protected func createClientTLS(request: H2Request): SocketClient {
        var host: String = request.url.hostname()
        let port: UInt16 = match(UInt16.tryParse(request.url.port())){
            case Some(v) => v
            case None =>
                if (request.url.toString().startsWith("https")) {
                    443
                } else {
                    80
                }
        }
        if (request.url.toString().startsWith("https")) {
            match(this.tlsClientCfg){
                case Some(v) =>
                    var vv = v
                    vv.verifyMode = VerifyNone
                    return createClientSocket(TCP, host, port, vv)
                case None =>
                    var cfg = TlsClientConfig("")
                    cfg.verifyMode = VerifyNone
                    this.tlsClientCfg = cfg
                    return createClientSocket(TCP, host, port, cfg)
            }
        } else {
            return createClientSocket(TCP, host, port)
        }
    }

    protected func createClientSocket(net: SocketNet, address: String, port: UInt16): SocketClient {
        let client: Socket = Socket(net, address, port)
        client.connect()
        return SocketC(client)
    }

    protected func createClientSocket(net: SocketNet, address: String, port: UInt16, cfg: TlsClientConfig): SocketClient {
        return TlsC(TlsSocket(net, address, port, cfg))
    }

    /* create a new h2clientconn */
    protected func dialClientConn(req: H2Request, addr: String, singleUse: Bool): H2ClientConn {
        let (host, ports, err): (String, String, String) = splitHostPort(addr)
        if (!err.isEmpty()) {
            throw Http2Exception("host illegal: " + err)
        }
        // TODO new TLS Config Domain.
        /* Only H2C is supported for the time being */
        return newClientConn(req, singleUse)
    }

    /* replace: H2ClientConn.createClientConn(this, client) */
    protected func newClientConn(req: H2Request, singleUse: Bool): H2ClientConn {
        let h2cc: H2ClientConn = H2ClientConn.createClientConn(this, createClientTLS(req))
        h2cc.singleUse = singleUse
        return h2cc
    }
}
