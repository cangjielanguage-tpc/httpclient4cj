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
        let transmitter: Transmitter = chain.getTransmitter()
        var followUpCount: Int64 = 0
        while (true) {
            transmitter.prepareToConnect(request)
            if (transmitter.isCanceled()) {throw Exception("Canceled") }
            var response: Response = Response.builder().build()
            var success: Bool = false
            try {
               response = chain.proceed(request, transmitter, Option<Exchange>.None)
               success = true
            } catch (e1: RouteException) {
                if (!recover(e1.getLastConnectException(), transmitter, false, request)) {
                    throw e1.getFirstConnectException()
                }
                continue
            } catch (e1: IOException) {
                if (!recover(e1, transmitter, !(e1 is H2ConnectionException), request)) {throw e1}
                continue
            } finally {
                if (!success) { transmitter.exchangeDoneDueToException() }
            }

            match(priorResponse) {
                case Some(resp) => response = response.newBuilder()
                .prevResponse(Option<Response>.Some(resp.newBuilder()
                    .body(Option<ResponseBody>.None)
                    .build()))
                    .build()
                case _ => ()
            }
            let route: Option<Route> = match (response.exchange) {
                case Some(ex) => ex.getConnection().getRoute()
                case None => Option<Route>.None
            }
            let followUp = followUpRequest(response, route)
            let exchange: Option<Exchange> = response.exchange
            let followUpBody: Option<RequestBody> = match (followUp) {
                case Some(r)  => r.getBody()
                case _ => return response
            }
            match (followUpBody) {
                case Some(b) => return response
                case None => ()
            }
            Util.closeQuietly(response.getBody())
            if (transmitter.hasExchange()) {
                exchange.getOrThrow().detachWithViolence();
            }
            followUpCount++
            if (followUpCount > MAX_FOLLOW_UPS) {
                throw ProtocolException("Too many follow-up requests: ${followUpCount}")
            }
            request = followUp.getOrThrow()
            priorResponse = Option<Response>.Some(response)
        }
        return Response.builder().build()
    }

    private func recover(e: Exception, transmitter: Transmitter, requestSendStarted: Bool, userRequest: Request) {
        if (!client.getRetryOnConnectionFailure()) {
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
    func followUpRequest(response: Response, route: Option<Route>): Option<Request> {
        let code: Int64 = response.code
        let method: String = response.getRequest().getMethod()
        match (code) {
            case 307 | 308 =>
                   // 307,308 If this is not a GET or HEAD request, the browser disables automatic redirection
                   if (method != "GET" && method != "HEAD") {
                       return Option<Request>.None
                   }
                   return redirectRequest(response)
            case 300 | 301 | 302 | 303 =>
                   return redirectRequest(response)
            case 401 =>
                   return client.getAuthenticator()(route, response)
            case 408 =>
                if (!client.getRetryOnConnectionFailure()) {
                   // The application layer has directed us not to retry the request.
                   return Option<Request>.None
                }
                match (response.getRequest().getBody()) {
                    case Some(body) => ()
                    case None => return Option<Request>.None
                }
                match (response.getPrevResponse()) {
                    case Some(resp) =>
                        if (resp.getCode() == HttpStatusCode.STATUS_REQUEST_TIMEOUT) {
                            return Option<Request>.None
                        }
                        ()
                    case _ => ()
                }
                if (retryAfter(response, 0) > 0) {
                    return Option<Request>.None
                }
                return response.getRequest()
            case 503 =>
                match (response.getPrevResponse()) {
                    case Some(resp) =>
                        if (resp.getCode() == HttpStatusCode.STATUS_GATEWAY_TIMEOUT) {
                            return Option<Request>.None
                        }
                        ()
                    case _ => ()
                }
                if (retryAfter(response, 1) == 0) {
                    return response.getRequest()
                }
                return Option<Request>.None
            case _ => return Option<Request>.None
        }
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
        let url: URL = response.getRequest().getUrl().resolveReference(URL.parseRequestURI(location))
        let method: String = response.getRequest().getMethod()
        if (location == "") {
            return Option<Request>.None
        }
        if (url.scheme != response.getRequest().getUrl().scheme && !client.getFollowSslRedirects()) {
            return Option<Request>.None
        }
        let requestBuilder: RequestBuilder  = response.getRequest().newBuilder()
        //redirects should also maintain the request body
        if (permitsRequestBody(method)) {
            if (redirectsToGet(method)) {
                requestBuilder.method("GET")
            } else {
                requestBuilder.method(method, body: response.getRequest().getBody())
                requestBuilder.removeHeader("Transfer-Encoding")
                requestBuilder.removeHeader("Content-Length")
                requestBuilder.removeHeader("Content-Type")
            }
        }
        // When redirecting across hosts, drop all authentication headers. This
        // is potentially annoying to the application layer since they have no
        // way to retain them.
        if (!Util.sameConnection(response.getRequest().getUrl(), url)) {
            requestBuilder.removeHeader("Authorization")
        }
        return Option<Request>.Some(requestBuilder.url(url).build())
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
        // currently ignores a HTTP-date, and assumes any non int 0 is a delay
        match (parseInt64(header)) {
            case Some(delay) => return delay
            case None => return Int64(Int32.Max)
        }
    }
}