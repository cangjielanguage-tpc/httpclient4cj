/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the BridgeInterceptor class.
 */
package okhttp


/**
 * The class is BridgeInterceptor inherited from Interceptor
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class BridgeInterceptor<: Interceptor {
    /* let member cookieJar type is CookieJar */
    private let cookieJar: CookieJar

    /**
     * The Function is init constructor
     *
     * @param cookieJar of CookieJar
     * @since 0.29.3
     */
    public init(cookieJar: CookieJar) {
        this.cookieJar = cookieJar
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
        let requestBuilder: RequestBuilder  = request.newBuilder()
        match(request.getBody()) {
            case Some(b) =>  
                requestBuilder.header("Content-Type", b.contentType())
                if (b.getContentLength() != -1) {
                    requestBuilder.header("Content-Length", "${b.getContentLength()}")
                    requestBuilder.removeHeader("Transfer-Encoding")
                } else {
                    requestBuilder.header("Transfer-Encoding", "chunked")
                    requestBuilder.removeHeader("Content-Length")
                }
                ()
            
            case _ => ()
        }
        if (request.getHeader("Host", "") == "") {
            requestBuilder.header("Host", request.getUrl().hostname())
        }
        if (request.getHeader("Connection", "") == "") {
            requestBuilder.header("Connection", "Keep-Alive")
        }

        var transparentGzip: Bool = false
        // If we add an "Accept-Encoding: gzip" header field we're responsible for also decompressing
        // the transfer stream.
        if (request.getHeader("Accept-Encoding", "") == "" && request.getHeader("Range", "") == "") {
           transparentGzip = true
           requestBuilder.header("Accept-Encoding", "gzip")
        }
        let cookies = cookieJar.cookies(request.getUrl())
        if (cookies.size != 0) {
           requestBuilder.header("Cookie", cookieHeader(cookies))
        }
        if (request.getHeader("User-Agent", "") == "") {
            requestBuilder.header("User-Agent", "okhttp4cj");
        }
        var response: Response =  chain.proceed(requestBuilder.build())
        let responseHeader: Header = response.getHeaders()
        //receiveHeaders(cookieJar, request.getUrl(), responseHeader)
        let responseBuilder: ResponseBuilder = response.newBuilder().request(request)
        if (transparentGzip && "gzip".equals(response.getHeader("Content-Encoding","")) && hasBody(response)) {
            let strippedHeader = response.getHeaders().clone()
            strippedHeader.remove("Content-Encoding")
            strippedHeader.remove("Content-Length")
            responseBuilder.header(strippedHeader)
            let contentType = response.getHeader("Content-Type","")
            responseBuilder.body(ResponseBody(contentType, -1,
                OkGzipSource(response.getBody().getOrThrow().getSource())))
        }
        return responseBuilder.build()
    }

    /*
     * The Function is cookieHeader
     *
     * @param cookies of Array<Cookie>
     *
     * @return Type of String
     * @since 0.29.3
     */
    func cookieHeader(cookies: Array<Cookie>): String {
        let sb: StringBuilder = StringBuilder()
        for (cookie in cookies) {
            sb.append("${; cookie}")
        }
        sb.remove(0..2)
        return "${sb}"
    }

    /*
     * The Function is receiveHeaders
     *
     * @param cookieJar of CookieJar
     * @param url of URL
     * @param header of Header
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func receiveHeaders(cookieJar: CookieJar, url: URL, header: Header): Unit {
        match(header.get("Set-Cookie")) {
            case Some (c) =>
                let cookies = Array<Cookie>(1, item:  Cookie(url.toString(), c))
                cookieJar.setCookies(url, cookies)
            case None => ()
        }
    }
}

    /**
     * The Function is hasBody
     *
     * @param response of Response
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func hasBody(response: Response): Bool {
        if (response.getRequest().getMethod().equals("HEAD")) {
            return false
        }
        let responseCode: Int64 = response.getCode()
        if ((responseCode < HttpStatusCode.STATUS_CONTINUE || responseCode >= HttpStatusCode.STATUS_OK) &&
            responseCode != HttpStatusCode.STATUS_NO_CONTENT &&
            responseCode != HttpStatusCode.STATUS_NOT_MODIFIED) {
            return true
        }
        let contentLength = response.getHeader("Content-Length", "")
        if (contentLength != "" && ((parseInt64(contentLength) ?? -1) != -1) ||
         "chunked".equals(response.getHeader("Transfer-Encoding", ""))) {
            return true
         }
        return false
    }

    public func contentLength(response: Response): Int64 {
        return contentLength(response.getHeaders())
    }

    public func contentLength(headers: Header): Int64 {
        return parseInt64(headers.get("Content-Length") ?? "") ?? -1
    }