/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the Transmitter class.
 */

package httpclient4cj

/**
 * The class is Transmitter
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Transmitter {
    /* var member client type is HttpClient */
    private var client: HttpClient

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
    private var address: Option<Address> = Option<Address>.None

    /* var member exchangeFinder type is Option<ExchangeFinder> */
    private var exchangeFinder: Option<ExchangeFinder> = None

    /* var member exchange type is Option<Exchange> */
    private var exchange: Option<Exchange> = None

    private var noExchanges: Bool = false
    private var exchangeRequestDone: Bool = false
    private var exchangeResponseDone: Bool = false
    var ref: Bool = true
    private let eventListener: EventListener

    /**
     * The Function is init constructor
     *
     * @param client of HttpClient
     * @param call of Call
     * @since 0.29.3
     */
    public init(client: HttpClient, call: Call) {
        this.client = client
        // 连接池由 HttpClient 构造期创建，所有 Call 共享同一实例，这里只读引用
        this.connectionPool = client.connectionPool
        // 与 OkHttp 一致：每个 Call 持有独立的 EventListener 实例
        this.eventListener = client.createEventListener(call)
        this.call = call
    }

    func getEventListener(): EventListener {
        return eventListener
    }

    /**
     * 标记该 Call 已结束。ref 的写入必须在连接池锁内进行，
     * 连接池清理逻辑在持锁状态下读取该字段。
     */
    func markCallFinished(): Unit {
        synchronized(connectionPool.mutex) {
            ref = false
        }
    }

    /**
     * The Function is cancel
     *
     * @since 0.29.3
     */
    public func cancel(): Unit {
        let exchangeToCancel: Option<Exchange>
        let connectionToCancel: Option<Connection>
        synchronized(connectionPool.mutex) {
            canceled = true
            exchangeToCancel = exchange
            connectionToCancel = match (exchangeFinder) {
                case Some(find) => match (find.getConnectingConnection()) {
                    case Some(conn) => Option<Connection>.Some(conn)
                    case None => this.connection
                }
                case None => this.connection
            }
        }
        match (exchangeToCancel) {
            case Some(cancelEx) => cancelEx.cancel()
            case None => match (connectionToCancel) {
                case Some(cancelConn) => cancelConn.cancel()
                case None => ()
            }
        }
    }

    /**
     * The Function is isCanceled
     *
     * @since 0.29.3
     */
    public func isCanceled(): Bool {
        synchronized(connectionPool.mutex) {
            return canceled
        }
    }

    /**
     * The Function is releaseConnectionNoEvents
     *
     * @return Type of Option<Socket>
     * @since 0.29.3
     */
    func releaseConnectionNoEvents(): Option<OKSocket> {
        let conn = connection.getOrThrow()
        let arr = conn.getTransmitters()

        for (index in 0..arr.size) {
            if (refEq(arr[index], this)) {
                arr.remove(at: index)
                break
            }
        }

        let released = conn
        this.connection = Option<Connection>.None

        if (arr.isEmpty()) {
            released.idleAtNanos = DateTime.now()
            if (connectionPool.connectionBecameIdle(released)) {
                return released.getSocket()
            }
        }

        return Option<OKSocket>.None
    }

    /**
     * The Function is acquireConnectionNoEvents
     *
     * @param connection of Connection
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func acquireConnectionNoEvents(connection: Option<Connection>): Unit {
        synchronized(connectionPool.mutex) {
            match (connection) {
                case Some(conn) =>
                    this.connection = conn
                    conn.transmitters.add(this)
                case None => throw HttpException("IllegalStateException")
            }
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
        match (this.request) {
            case Some(r) =>
                if (Util.sameConnection(r.getUrl(), request.getUrl())) {
                    if (exchangeFinder.getOrThrow().hasRouteToTry()) {
                        return
                    }
                }
                if (hasExchange()) {
                    throw IllegalStateException("hasExchange")
                }
                if (hasExchangeFinder()) {
                    maybeReleaseConnection(true)
                    exchangeFinder = None
                }
            case None => ()
        }
        this.request = request
        let addr = createAddress(request.getUrl())
        address = Option<Address>.Some(addr)
        this.exchangeFinder = Option<ExchangeFinder>.Some(
            ExchangeFinder(this, connectionPool, address.getOrThrow(), call, eventListener))
    }

    private func createAddress(url: URL): Address {
        // 内部只读场景直接复用客户端持有的列表，避免取 getter 时的防御性拷贝
        if (url.scheme == "https") {
            return Address(url, client.protocols, client.getTlsConfig())
        } else {
            return Address(url, client.protocols)
        }
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
    func newExchange(_: Chain, doExtensiveHealthChecks: Bool): Exchange {
        return createExchange(doExtensiveHealthChecks)
    }

    /**
     * 快路径创建 Exchange：不构造 Chain，直接复用 ExchangeFinder/连接池。
     */
    func newExchangeForFastPath(): Exchange {
        return createExchange(false)
    }

    private func createExchange(doExtensiveHealthChecks: Bool): Exchange {
        let finder: ExchangeFinder = exchangeFinder.getOrThrow()
        let exchangeCodec: ExchangeCodec = finder.find(client, doExtensiveHealthChecks)
        let result: Exchange = Exchange(this, call, finder, exchangeCodec, eventListener)
        synchronized(connectionPool.mutex) {
            this.exchange = Some(result)
            this.exchangeRequestDone = false
            this.exchangeResponseDone = false
        }
        return result
    }

    public func noMoreExchanges(): Unit {
        synchronized(connectionPool.mutex) {
            noExchanges = true
        }
        maybeReleaseConnection(false)
    }

    private func maybeReleaseConnection(force: Bool): Unit {
        var socket: Option<OKSocket> = None
        var callEnd: Bool
        synchronized(connectionPool.mutex) {
            let hase = hasExchange()
            if (force && hase) {
                throw IllegalStateException("cannot release connection while it is in use")
            }

            if (hasConnection() && !hase && (force || noExchanges)) {
                socket = releaseConnectionNoEvents()
            } else {
                socket = None
            }

            callEnd = noExchanges && !hase
        }
        Util.closeQuietly(socket)

        if (callEnd) {
            eventListener.callEnd(call)
        }
    }

    public func hasExchangeFinder() {
        return has(this.exchangeFinder)
    }

    public func hasConnection(): Bool {
        synchronized(connectionPool.mutex) {
            return match (this.connection) {
                case Some(_) => true
                case None => false
            }
        }
    }

    public func hasExchange(): Bool {
        synchronized(connectionPool.mutex) {
            return has(exchange)
        }
    }

    func exchangeMessageDone(exchange: Exchange, requestDone: Bool, responseDone: Bool) {
        var exchangeDone = false
        synchronized(connectionPool.mutex) {
            if (!refEq(this.exchange.getOrThrow(), exchange)) {
                // from detached violently
                return
            }

            var changed = false

            if (requestDone) {
                if (!exchangeRequestDone) {
                    changed = true
                }
                this.exchangeRequestDone = true
            }

            if (responseDone) {
                if (!exchangeResponseDone) {
                    changed = true
                }
                this.exchangeResponseDone = true
            }

            if (exchangeRequestDone && exchangeResponseDone && changed) {
                exchangeDone = true
                this.exchange.getOrThrow().getConnection().successCount++
                this.exchange = None
            }
        }
        if (exchangeDone) {
            maybeReleaseConnection(false)
        }
    }

    public func exchangeDoneDueToException(): Unit {
        synchronized(connectionPool.mutex) {
            if (noExchanges) {
                throw IllegalStateException("")
            }
            exchange = None
        }
    }

    public func canRetry(): Bool {
        let ex = exchangeFinder.getOrThrow()
        let flag1 = ex.getHasStreamFailure()
        let flag2 = ex.hasRouteToTry()
        return flag1 && flag2
    }
}
