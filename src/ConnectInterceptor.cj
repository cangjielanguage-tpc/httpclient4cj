/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ConnectInterceptor class.
 */
package okhttp

/**
 * The class is ConnectInterceptor inherited from Interceptor
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ConnectInterceptor<: Interceptor {
    /** let member client type is OkHttpClient */
    public let client: OkHttpClient

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @since 0.29.3
     */
    public init (client: OkHttpClient) {
        this.client = client
    }

    /**
     * The Function is intercept
     *
     * @param chain of Chain
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func intercept(chain: Chain): Response {
       let transmitter: Transmitter = chain.getTransmitter()
       let request: Request = chain.getRequest()
       let doExtensiveHealthChecks: Bool = !request.getMethod().equals("GET")
       return chain.proceed(request, chain.getTransmitter(),transmitter.newExchange(chain, doExtensiveHealthChecks))

    }
}