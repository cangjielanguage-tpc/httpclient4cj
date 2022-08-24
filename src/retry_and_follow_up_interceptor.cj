/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the RetryAndFollowUpInterceptor class.
 */
package okhttp

from encoding import url.*
from std import convert.*

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
        this.client = client
    }

    /*max redirect count*/
    private static let  MAX_FOLLOW_UPS: Int64 = 20

    /**
     * The Function is intercept
     *
     * @param chain of Chain
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func intercept(chain: Chain): Response {
        var request: Request = chain.getRequest()
        var priorResponse: Option<Response> = Option<Response>.None
        let transmitter: Transmitter = chain.getTransmitter();

        var followUpCount: Int64 = 0
        while (true) {
            transmitter.prepareToConnect(request)
            if (transmitter.isCanceled()) {
                throw Exception("Canceled")
            }
            var response: Response
            var success: Bool = false
            try {
                //invoke next interceptor
               response = chain.proceed(request, transmitter, Option<Exchange>.None)
               success = true
            } catch (e1: RouteException) {
                //TODO confirm redirect condition
                if (!recover(e1.getLastConnectException(), transmitter, false, request)) {
                    throw e1.getFirstConnectException()
                }
                continue
            } catch (e1: HttpException) {
                if (!recover(e1, transmitter, !(e1 is H2ConnectionException), request)) {
                    throw e1
                }
                continue
            } finally {
                if (!success) {
                    transmitter.exchangeDoneDueToException();
                }
            }
            match(priorResponse) {
                case Some(resp) => response = response.newBuilder()
                      .prevResponse(Option<Response>.Some(resp.newBuilder()
                              .build()))
                      .build()
                case _ => ()
            }

            let followUp = followUpRequest(response)
            match (followUp) {
                case Some(r)  => ()
                case _ => return response
            }

            // TODO requestBody
            followUpCount++
            if (followUpCount > MAX_FOLLOW_UPS) {
                throw ProtocolException("Too many follow-up requests: ${followUpCount}");
            }
            request = followUp.getOrThrow()
            priorResponse = Option<Response>.Some(response)
        }
        return Response.builder().build()
    }

    private func recover(e: Exception, transmitter: Transmitter, requestSendStarted: Bool, userRequest: Request) {
        if(!client.getRetryOnConnectionFailure()) {
            return false
        }
        if (isRecoverable(e, requestSendStarted)) {
            return false
        }

        if (!transmitter.canRetry()) {
            return false
        }
        return true
    }

    private func isRecoverable(e: Exception, requestSendStarted: Bool): Bool {
        match (e) {
            case p: ProtocolException => return false
            case timeOut: SocketTimeoutException => return !requestSendStarted
            case tls: TlsException => return false
            case _  => return true
        }
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
            // TODO proxy
            case 307 | 308 => {
                    // 307,308 If this is not a GET or HEAD request, the browser disables automatic redirection
                    if (method == "GET" || method == "HEAD") {
                        return Option<Request>.None
                    }
                    return redirectRequest(response)
                }
            case 300 | 301 | 302 | 303 =>{
                    return redirectRequest(response)
                }
            case 408 => {
                 if (!client.getRetryOnConnectionFailure()) {
                    // The application layer has directed us not to retry the request.
                    return Option<Request>.None
                 }
                 // TODO RequestBody
                match (response.getPrevResponse()) {
                    case Some(resp) =>
                        if (resp.getCode() == HttpStatusCode.STATUS_REQUEST_TIMEOUT) {
                            return Option<Request>.None
                        }
                    case _ => return Option<Request>.None
                }

                if (retryAfter(response, 0) > 0) {
                    return Option<Request>.None
                }
                return response.getRequest()

            }
            case 503 => {
                match (response.getPrevResponse()) {
                    case Some(resp) =>
                        if (resp.getCode() == HttpStatusCode.STATUS_GATEWAY_TIMEOUT) {
                            return Option<Request>.None
                        }
                    case _ => return Option<Request>.None
                }
                if (retryAfter(response, 1) == 0) {
                    return response.getRequest()
                }
                return Option<Request>.None
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
        let method: String = response.getRequest().getMethod()
        if (location == "") {
            return Option<Request>.None
        }
        let requestBuilder: RequestBuilder  = response.getRequest().newBuilder()
        //redirects should also maintain the request body
        if (!method.equals("PROPFIND")) {
            requestBuilder.method("GET")
            ()
        } else {
            requestBuilder.method(method)
            //TODO set re4questBody
            requestBuilder.removeHeader("Transfer-Encoding")
            requestBuilder.removeHeader("Content-Length")
            requestBuilder.removeHeader("Content-Type")
            ()
        }
        let locationUrl: URL
        try {
            locationUrl =  URL.parseRequestURI(location)
            if(locationUrl.scheme != response.getRequest().getUrl().scheme) {
                return Option<Request>.None
            }
            // When redirecting across hosts, drop all authentication headers. This
            // is potentially annoying to the application layer since they have no
            // way to retain them.
            if (!Util.sameConnection(response.getRequest().getUrl(), locationUrl)) {
                requestBuilder.removeHeader("Authorization")
            }
            return Option<Request>.Some(requestBuilder.url(locationUrl).build())
        } catch (e: Exception){
            return Option<Request>.None
        }

    }

    /*
     * The Function is retryAfter
     *
     * @param userResponse of Response
     * @param defaultDelay of Int64
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    func retryAfter( userResponse: Response,  defaultDelay: Int64): Int64 {
        let header: String = userResponse.getHeader("Retry-After", "");

        if (header == "") {
          return defaultDelay;
        }

        // https://tools.ietf.org/html/rfc7231#section-7.1.3
        // currently ignores a HTTP-date, and assumes any non int 0 is a delay
        match (parseInt64(header)) {
            case Some(delay) => return delay
            case None => return 1
        }
    }
}