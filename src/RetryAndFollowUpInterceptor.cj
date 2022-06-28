/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the RetryAndFollowUpInterceptor class.
 */
package okhttp

from encoding import url.*
from net import http.HttpStatusCode

/**
 * The class is RetryAndFollowUpInterceptor inherited from Interceptor
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class RetryAndFollowUpInterceptor<: Interceptor {
    /* let member client type is OkHttpClient */
    private let  client: OkHttpClient

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @since 0.29.3
     */
    public init(client: OkHttpClient) {
        this.client = client;
    }


    /* let member MAX_FOLLOW_UPS type is Int64 */
    private static let  MAX_FOLLOW_UPS: Int64 = 20;

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
        while (true) {
            var response: Response
            try {
                //invoke next interceptor
               response =  chain.proceed(request)
            } catch (e: Exception) {
                //TODO confirm redirect condition
            } finally {

            }
            match (followUpRequest(response)) {
                case Some(r)  => return response
                case _ => return response
            }
        }
        return Response.builder().build()
    }


    /*
     * The Function is followUpRequest
     *
     * @param response of Response
     *
     * @return Type of Option<Request>
     * @since 0.29.3
     */
    func followUpRequest(response: Response): Option<Request> {
        let code: Int64 = response.code
        let method: String = response.getRequest().getMethod()
        match (code) {
            case 307 | 308 => {
                    // 307,308 If this is not a GET or HEAD request, the browser disables automatic redirection
                    if (method == "GET" || method == "HEAD") {
                        return Option<Request>.None
                    }
                    return redirectRequest(response)
                }
            case 300 | 301 |
                302 | 303 =>{
                    return redirectRequest(response)
                }
            case _ => return Option<Request>.None
        }


    return Option<Request>.None

    }

    /*
     * The Function is redirectRequest
     *
     * @param response of Response
     *
     * @return Type of Option<Request>
     * @since 0.29.3
     */
    func redirectRequest(response: Response): Option<Request> {
        if (!client.getFollowRedirects()) {
            return Option<Request>.None
        }
        let location: String = response.getHeader("Location", "")
        if (location == "") {
            return Option<Request>.None
        }
         return Option<Request>.None

    }
}