/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkHttpClientBuilder class.
 */
package okhttp

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
    var followRedirectsBuild: Bool = false
    /* var member retryOnConnectionFailureBuild type is Bool */
    var retryOnConnectionFailureBuild: Bool = true
    /* var member connectionPoolBuild type is Option<ConnectionPool> */
    var connectionPoolBuild: Option<ConnectionPool> = Option<ConnectionPool>.None
    /* var member cookieJarBuild type is CookieJar */
    var cookieJarBuild: CookieJar = CookieJar()
    var connectTimeoutBuild: Option<Duration> = Option<Duration>.None
    var readTimeoutBuild: Option<Duration> = Option<Duration>.None
    var writeTimeoutBuild: Option<Duration> = Option<Duration>.None

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
    public func cookieJar(cookieJar: CookieJar): OkHttpClientBuilder {
        this.cookieJarBuild = cookieJar
        return this
    }

    public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder{
        this.connectTimeoutBuild  = Option<Duration>.Some(connectTimeout)
        return this
    }

    public func readTimeout(readTimeout: Duration): OkHttpClientBuilder{
        this.readTimeoutBuild  = Option<Duration>.Some(readTimeout)
        return this
    }

    public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder{
        this.writeTimeoutBuild = Option<Duration>.Some(writeTimeout)
        return this
    }

}

