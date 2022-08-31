/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkHttpClientBuilder class.
 */
package okhttp

from net import tls.*

/**
 * The class is OkHttpClientBuilder inherited from Builder<OkHttpClient>
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class OkHttpClientBuilder <: Builder<OkHttpClient> {
    /* var member dispatcherBuild type is Dispatcher */
    var dispatcherBuild: Dispatcher = Dispatcher()
    /* var member interceptorsBuild type is ArrayList<Interceptor> */
    var interceptorsBuild: ArrayList<Interceptor> = ArrayList<Interceptor>()
    /* var member networkInterceptorsBuild type is ArrayList<Interceptor> */
    var networkInterceptorsBuild: ArrayList<Interceptor> = ArrayList<Interceptor>()
    /* var member followRedirectsBuild type is Bool */
    var followRedirectsBuild: Bool = true
    /* var member retryOnConnectionFailureBuild type is Bool */
    var retryOnConnectionFailureBuild: Bool = true
    /* var member connectionPoolBuild type is Option<ConnectionPool> */
    var connectionPoolBuild: Option<ConnectionPool> = Option<ConnectionPool>.None
    /* var member cookieJarBuild type is CookieJar */
    var cookieJarBuild: CookieJar = CookieJar()
    var connectTimeoutBuild: Option<Duration> = Option<Duration>.Some(Duration.millisecond(10000))
    var readTimeoutBuild: Option<Duration> = Option<Duration>.Some(Duration.millisecond(10000))
    var writeTimeoutBuild: Option<Duration> = Option<Duration>.Some(Duration.millisecond(10000))
    var tlsConfigBuild: Option<TlsClientConfig> = None
    var protocolsBuild: ArrayList<String> = ArrayList<String>([Protocol.get("HTTP/1.1").toString()])

    /**
     * The Function is build
     *
     * @return Type of OkHttpClient
     * @since 0.29.3
     */
    public func build(): OkHttpClient {
         return OkHttpClient(this)
    }

    /**
     * The Function is dispatcher
     *
     * @param dispatcher of Dispatcher
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func dispatcher(dispatcher: Dispatcher): OkHttpClientBuilder {
       this.dispatcherBuild = dispatcher
       return this
    }

    /**
     * The Function is followRedirects
     *
     * @param followRedirects of Bool
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func followRedirects(followRedirects: Bool): OkHttpClientBuilder {
       this.followRedirectsBuild = followRedirects
       return this
    }

    /**
     * The Function is retryOnConnectionFailure
     *
     * @param retryOnConnectionFailure of Bool
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func retryOnConnectionFailure(retryOnConnectionFailure: Bool): OkHttpClientBuilder {
       this.retryOnConnectionFailureBuild = retryOnConnectionFailure
       return this
    }

    /**
     * The Function is connectionPool
     *
     * @param connectionPool of Option<ConnectionPool>
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func connectionPool(connectionPool: Option<ConnectionPool>): OkHttpClientBuilder {
        this.connectionPoolBuild = connectionPool
        return this
    }

    /**
     * The Function is addInterceptor
     *
     * @param interceptor of Interceptor
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder {
        this.interceptorsBuild.append(interceptor)
        return this
    }

    /**
     * The Function is addNetworkInterceptor
     *
     * @param interceptor of Interceptor
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    public func addNetworkInterceptor(interceptor: Interceptor): OkHttpClientBuilder {
        this.networkInterceptorsBuild.append(interceptor)
        return this
    }

    /**
     * The Function is cookieJar
     *
     * @param cookieJar of CookieJar
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.29.3
     */
    func cookieJar(cookieJar: CookieJar): OkHttpClientBuilder {
        this.cookieJarBuild = cookieJar
        return this
    }

    /**
     * The Function is connectTimeout
     *
     * @param connectTimeout of Duration
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.30.4
     */
    public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder{
        this.connectTimeoutBuild  = Option<Duration>.Some(connectTimeout)
        return this
    }

    /**
     * The Function is readTimeout
     *
     * @param readTimeout of Duration
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.30.4
     */
    public func readTimeout(readTimeout: Duration): OkHttpClientBuilder{
        this.readTimeoutBuild  = Option<Duration>.Some(readTimeout)
        return this
    }

    /**
     * The Function is writeTimeout
     *
     * @param writeTimeout of Duration
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.30.4
     */
    public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder{
        this.writeTimeoutBuild = Option<Duration>.Some(writeTimeout)
        return this
    }

    /**
     * The Function is tlsConfig
     *
     * @param path of String
     *
     * @return Type of OkHttpClientBuilder
     * @since 0.30.4
     */
    public func tlsConfig(path: String): OkHttpClientBuilder {
        this.tlsConfigBuild = TlsClientConfig(path)
        return this
    }

    public func protocols(protocols: ArrayList<String>): OkHttpClientBuilder {
        if (!protocols.contains(Protocol.get("H2_PRIOR_KNOWLEDGE").toString())
                  && !protocols.contains(Protocol.get("HTTP/1.1").toString())) {
                throw  IllegalArgumentException(
                    "protocols must contain h2_prior_knowledge or http/1.1")
        }
        if (protocols.contains(Protocol.get("H2_PRIOR_KNOWLEDGE").toString()) && protocols.size() > 1) {
            throw  IllegalArgumentException(
                "protocols containing h2_prior_knowledge cannot use other protocols");
        }
        if (protocols.contains(Protocol.get("HTTP/1.0").toString())) {
            throw IllegalArgumentException("protocols must not contain http/1.0")
        }
        if (protocols.size() == 0) {
            throw IllegalArgumentException("protocols must not contain empty")
        }
        this.protocolsBuild = protocols
        return this
    }

}

