/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the CallServerInterceptor class.
 */
package okhttp

/**
 * The class is CallServerInterceptor inherited from Interceptor
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class CallServerInterceptor<: Interceptor {
    /** let member forWebSocket type is Bool */
    public let forWebSocket: Bool

    /**
     * The Function is init constructor
     *
     * @param forWebSocket of Bool
     * @since 0.29.3
     */
    public init (forWebSocket: Bool) {
        this.forWebSocket = forWebSocket
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
        let request: Request = chain.getRequest()
        let exchange: Exchange = chain.getExchange()
        //TODO
        exchange.write(request)
        let respB = exchange.readResponseHeaders()
        .body(exchange.openResponseBody())
        .request(request)
        return respB.build()
    }
}