/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the HttpClient class.
 */

package httpclient4cj

/**
 * The class is HttpClient
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class HttpClient {
    // 以下配置在构造后不再变化（与 OkHttp 的 final 字段语义一致），
    // 因此可以被多个线程安全地共享读取。
    /* var member dispatcher type is Dispatcher */
    private let dispatcher: Dispatcher

    /* var member interceptors type is ArrayList<Interceptor> */
    private let interceptors: ArrayList<Interceptor>

    /* var member networkInterceptors type is ArrayList<Interceptor> */
    private let networkInterceptors: ArrayList<Interceptor>

    /* var member followRedirects type is Bool */
    private let followRedirects: Bool

    /* var member retryOnConnectionFailure type is Bool */
    private let retryOnConnectionFailure: Bool

    /* var member connectionPool type is ConnectionPool，构造期创建后不再变更 */
    let connectionPool: ConnectionPool

    /* var member cookieJar type is CookieJar */
    private let cookieJar: CookieJar
    private let connectTimeout: Option<Duration>
    private let readTimeout: Option<Duration>
    private let writeTimeout: Option<Duration>

    let protocols: ArrayList<String>
    private let tlsConfig: Option<TlsClientConfig>
    private let authenticator: (Option<Route>, Response) -> Option<Request>
    private let followSslRedirects: Bool
    private let eventListener: EventListener
    private let eventListenerFactory: Option<(Call) -> EventListener>
    private let authenticatorIsDefault: Bool
    private let listenerIsDefault: Bool
    private let cache: Option<Cache>
    // 无自定义拦截器时复用内建链：构造期一次性构建，之后只读
    private var builtinChain: Option<ArrayList<Interceptor>> = Option<ArrayList<Interceptor>>.None
    private var builtinWsChain: Option<ArrayList<Interceptor>> = Option<ArrayList<Interceptor>>.None

    /**
     * The Function is init constructor
     *
     * @param builder of HttpClientBuilder
     * @since 0.29.3
     */
    public init(builder: HttpClientBuilder) {
        this.dispatcher = builder.dispatcherBuild
        // 拷贝 Builder 的拦截器列表，避免构造后仍与 Builder 共享可变 ArrayList
        this.interceptors = builder.interceptorsBuild.clone()
        this.networkInterceptors = builder.networkInterceptorsBuild.clone()
        this.followRedirects = builder.followRedirectsBuild
        this.followSslRedirects = builder.followSslRedirectsBuild
        this.retryOnConnectionFailure = builder.retryOnConnectionFailureBuild
        // 与 OkHttp 一致：连接池在客户端构造期创建，所有 Call 共享同一实例
        this.connectionPool = match (builder.connectionPoolBuild) {
            case Some(pool) => pool
            case None => ConnectionPool()
        }
        this.cookieJar = builder.cookieJarBuild
        this.connectTimeout = builder.connectTimeoutBuild
        this.readTimeout = builder.readTimeoutBuild
        this.writeTimeout = builder.writeTimeoutBuild
        this.tlsConfig = builder.tlsConfigBuild
        this.protocols = builder.protocolsBuild
        this.authenticator = builder.authenticatorBuild
        this.eventListener = builder.listenerBuild
        this.eventListenerFactory = builder.listenerFactoryBuild
        this.authenticatorIsDefault = builder.authenticatorIsDefault
        this.listenerIsDefault = builder.listenerIsDefault
        this.cache = builder.cacheBuild

        // 无自定义拦截器时在构造期预构建内建链，避免请求线程上的惰性写共享状态
        if (this.interceptors.isEmpty() && this.networkInterceptors.isEmpty()) {
            this.builtinChain = Option<ArrayList<Interceptor>>.Some(buildInterceptorChain(false))
            this.builtinWsChain = Option<ArrayList<Interceptor>>.Some(buildInterceptorChain(true))
        }
    }

    /**
     * The Function is builder
     *
     * @return Type of HttpClientBuilder
     * @since 0.29.3
     */
    public static func builder(): HttpClientBuilder {
        return HttpClientBuilder()
    }

    /**
     * The Function is newCall
     *
     * @param request of Request
     *
     * @return Type of Call
     * @since 0.29.3
     */
    public func newCall(request: Request): Call {
        return RealCall.newRealCall(this, request, false)
    }

    /**
     * The Function is getFollowRedirects
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func getFollowRedirects(): Bool {
        return followRedirects
    }

    /**
     * The Function is getRetryOnConnectionFailure
     *
     * @since 0.29.3
     */
    public func getRetryOnConnectionFailure() {
        return retryOnConnectionFailure
    }

    /**
     * The Function is getConnectionPool
     *
     * @return Type of Option<ConnectionPool>
     * @since 0.29.3
     */
    public func getConnectionPool(): Option<ConnectionPool> {
        return Option<ConnectionPool>.Some(connectionPool)
    }

    /**
     * The Function is getDispatcher
     *
     * @return Type of Dispatcher
     * @since 0.29.3
     */
    public func getDispatcher(): Dispatcher {
        return dispatcher
    }

    /**
     * The Function is getInterceptors
     *
     * @return Type of ArrayList<Interceptor>
     * @since 0.29.3
     */
    public func getInterceptors(): ArrayList<Interceptor> {
        // 返回副本，避免调用方修改影响客户端内部状态
        return interceptors.clone()
    }

    /**
     * The Function is getNetworkInterceptors
     *
     * @return Type of ArrayList<Interceptor>
     * @since 0.29.3
     */
    public func getNetworkInterceptors(): ArrayList<Interceptor> {
        // 返回副本，避免调用方修改影响客户端内部状态
        return networkInterceptors.clone()
    }

    /**
     * The Function is getCookieJar
     *
     * @return Type of CookieJar
     * @since 0.29.3
     */
    public func getCookieJar(): CookieJar {
        return cookieJar
    }

    public func getConnectTimeout(): Option<Duration> {
        return connectTimeout
    }

    public func getReadTimeout(): Option<Duration> {
        return readTimeout
    }

    public func getWriteTimeout(): Option<Duration> {
        return writeTimeout
    }

    public func getProtocols(): ArrayList<String> {
        // 返回副本，避免调用方修改影响客户端内部状态
        return protocols.clone()
    }

    public func getTlsConfig(): Option<TlsClientConfig> {
        return tlsConfig
    }

    public func getAuthenticator(): (Option<Route>, Response) -> Option<Request> {
        return authenticator
    }

    public func getFollowSslRedirects(): Bool {
        return followSslRedirects
    }

    /**
     * 返回配置的监听器实例。使用 eventListenerFactory 时该实例仅作默认回退，
     * 真实监听器请通过 createEventListener 按 Call 获取。
     */
    public func getEventListener(): EventListener {
        return eventListener
    }

    /**
     * 为单个 Call 创建监听器：配置了工厂则每 Call 一份，否则复用共享实例。
     */
    func createEventListener(call: Call): EventListener {
        return match (eventListenerFactory) {
            case Some(factory) => factory(call)
            case None => eventListener
        }
    }

    public func getCache(): Option<Cache> {
        return cache
    }

    // 简单 GET 快路径门控：任一条件不满足则回退通用拦截器链
    func canUseFastPath(request: Request): Bool {
        if (!interceptors.isEmpty() || !networkInterceptors.isEmpty()) {
            return false
        }
        if (has(cache)) {
            return false
        }
        match (cookieJar) {
            case _: NoCookieJar => ()
            case _ => return false
        }
        if (!authenticatorIsDefault || !listenerIsDefault) {
            return false
        }
        // 仅纯 HTTP/1.1；默认 TLS 配置始终存在，因此用 URL scheme 判断是否走 TLS
        if (protocols.size != 1 || !equalsIgnoreCase(protocols[0], Protocol.HTTP_1_1.toString())) {
            return false
        }
        if (request.getUrl().scheme != "http") {
            return false
        }
        // 这些配置非默认时会改变响应处理语义，直接走通用链
        if (!followRedirects || !followSslRedirects || !retryOnConnectionFailure) {
            return false
        }
        let method = request.getMethod()
        if (method != "GET") {
            return false
        }
        if (has(request.getBody())) {
            return false
        }
        if (equalsIgnoreCase("close", request.getHeader("Connection", ""))) {
            return false
        }
        // 无缓存时 only-if-cached 应返回 504 而不是发起网络请求
        if (request.getHeader("Cache-Control", "") != "" && request.getCacheControl().onlyIfCached()) {
            return false
        }
        return true
    }

    // 内建链在构造期预构建，这里只读；有自定义拦截器时每次按当前配置构建
    func getInterceptorChain(forWebSocket: Bool): ArrayList<Interceptor> {
        let cached = if (forWebSocket) {
            builtinWsChain
        } else {
            builtinChain
        }
        return match (cached) {
            case Some(v) => v
            case None => buildInterceptorChain(forWebSocket)
        }
    }

    private func buildInterceptorChain(forWebSocket: Bool): ArrayList<Interceptor> {
        let result: ArrayList<Interceptor> = ArrayList<Interceptor>()
        result.add(all: this.interceptors)
        result.add(RetryAndFollowUpInterceptor(this))
        result.add(BridgeInterceptor(cookieJar))
        result.add(CacheInterceptor(cache))
        result.add(ConnectInterceptor(this))
        if (!forWebSocket) {
            result.add(all: networkInterceptors)
        }
        result.add(CallServerInterceptor(forWebSocket))
        return result
    }
}
