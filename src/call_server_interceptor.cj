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
        let response = exchange.readResponseHeaders()
        .body(exchange.openResponseBody())
        .request(request).build()
        let code = response.getCode()
        if ("close".equals(response.getRequest().getHeader("Connection","")) ||
            "close".equals(response.getHeader("Connection",""))) {
            exchange.noNewExchangesOnConnection()
        }

        if (code ==204 || code == 205) {
            match (response.getBody()) {
                case Some(body) =>
                   if (body.getContentLength() > 0) {
                      throw ProtocolException("HTTP ${code} had non-zero Content-Length: ${body.getContentLength()}")
                   }
                case None => ()
           }

        }
        return response
    }
}