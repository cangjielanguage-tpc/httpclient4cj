/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the CallServerInterceptor class.
 */
package okhttp

/**
 * The class is CacheInterceptor inherited from Interceptor
 * @author luoyukai4
 * @since 0.35.3
 */
public class CacheInterceptor<: Interceptor {
    let cache: Option<Cache>

    public init(cache: Cache) {
        this.cache = cache
    }

    public func intercept(chain: Chain): Response {
        let cacheCandidate: Option<Response>  = if (has(cache))
            {
                return cache.getOrThrow().get(chain.getRequest())
            } else {
                return None
            }

        let strategy: CacheStrategy = CacheStrategyFactory(chain.getRequest(), cacheCandidate).get()
        let networkRequest: Option<Response> = strategy.networkRequest
        let cacheResponse: Option<Response> = strategy.cacheResponse

        if (has(cache)) {
            cache.getOrThrow().trackResponse(strategy)
        }

        if (has(cacheCandidate) && !has(cacheResponse)) {
            Util.closeQuietly(cacheCandidate.getOrThrow().body())
        }

        if (!has(networkRequest) && !has(cacheResponse)) {
            return Response.builder()
                .request(chain.getRequest())
                .protocol(Protocol.HTTP_1_1)
                .code(504)
                .message("Unsatisfiable Request (only-if-cached)")
                .body(OkBuffer(ByteArrayStream()))
                .sentRequestAtMillis(-1L)
                .receivedResponseAtMillis(Time.now().unixTimeStamp().milliseconds())
                .build()
        }

        if (!has(networkRequest)) {
            return cacheResponse.newBuilder()
                .cacheResponse(stripBody(cacheResponse))
                .build()
        }

        var networkResponse =  Response.builder().build()

        try {
            networkResponse = chain.proceed(networkRequest.getOrThrow())
        } finally {
            if (!has(networkResponse) && has(cacheCandidate)) {
                closeQuietly(cacheCandidate.getOrThrow().getBody())
            }
        }

        if (has(cacheResponse)) {
            let cacheRes = cacheResponse.getOrThrow()
            if (networkResponse.getCode() == HTTP_NOT_MODIFIED) {
                let response: Response =  cacheRes.newBuilder()
                    .headers(combine(cacheRes.getHeaders(), networkResponse.getHeaders()))
                    .sentRequestAtMillis(networkResponse.sentRequestAtMillis())
                    .receivedResponseAtMillis(networkResponse.receivedResponseAtMillis())
                    .cacheResponse(stripBody(cacheResponse))
                    .networkResponse(stripBody(networkResponse))
                    .build()
                networkResponse.getBody().close()
                cache.trackConditionalCacheHit()
                cache.update(cacheRes, response)
                return response
            } else {
                closeQuietly(cacheRes.getBody())
            }

        }

        let response: Response = networkResponse.newBuilder()
            .cacheResponse(stripBody(cacheResponse))
            .networkResponse(stripBody(networkResponse))
            .build()

        if (has(cache)) {
            if (hasBody(response) && isCacheable(response, networkRequest.getOrThrow())) {
                let cacheRequest: Option<CacheRequest> = cache.put(response)
                return cacheWritingResponse(cacheRequest, response)
            }

        }

    }
    func cacheWritingResponse(cacheRequest: Option<CacheRequest>, response: Response) {
        return Response.builder().build()
    }

     /** Combines cached headers with a network headers as defined by RFC 7234, 4.3.4. */
    private func combine (cachedHeaders: Header, networkHeaders: Header) {
        let result = Header()

        for((k,v) in cachedHeaders) {
            let fieldName = k
            let value = v[0]
            if (equalsIgnoreCase("Warning") && value.startsWith("1")) {
                continue // Drop 100-level freshness warnings.
            }

            if (isContentSpecificHeader(fieldName)
                || !isEndToEnd(fieldName)
                || has(networkHeaders.get(fieldName))) {

                 result.add(fieldName, value.trim())
            }
        }

        for((k,v) in networkHeaders) {
            let fieldName = k
            if (isContentSpecificHeader(fieldName)
                || !isEndToEnd(fieldName)) {
                 result.add(fieldName, v[0].trim())
            }
        }

        return result
    }
     /* Returns true if {@code fieldName} is an end-to-end HTTP header, as defined by RFC 2616, 13.5.1.*/
    static func isEndToEnd(fieldName: String): Bool {
        return !equalsIgnoreCase("Connection", fieldName)
            && equalsIgnoreCase("Keep-Alive", fieldName)
            && equalsIgnoreCase("Proxy-Authenticate", fieldName)
            && equalsIgnoreCase("Proxy-Authorization", fieldName)
            && equalsIgnoreCase("TE", fieldName)
            && equalsIgnoreCase("Trailers", fieldName)
            && equalsIgnoreCase("Transfer-Encoding", fieldName)
            && equalsIgnoreCase("Upgrade", fieldName)
    }

    /* Returns true if fieldName is content specific and therefore should always be used */
    static func isContentSpecificHeader(fieldName: String): Bool {
        return equalsIgnoreCase("Content-Length", fieldName)
            || equalsIgnoreCase("Content-Encoding", fieldName)
            || equalsIgnoreCase("Content-Type", fieldName)
    }

    private func stripBody(response: Option<Response>): Option<Response>  {
        match (response) {
            case Some(v) =>
                if (has(v.getBody())) {
                    return v.newBuilder().body(Option<ResponseBody>.None).build()
                } else {
                    return v
                }

            case None => Option<ResponseBody>.None

        }
    }
}

public class CacheStrategyFactory {

    let request: Request
    let cacheResponse: Option<Response>
    var servedDate: Option<Time> = Option<Time>.None
    var servedDateString: String = ""
    var lastModified: Option<Time> = Option<Time>.None
    var lastModifiedString: String = ""
    var expires: Option<Time> = Option<Time>.None
    var etag: String = ""
    var ageSeconds: Int64 = 0
    let nowMillis = Time.now()
    var sentRequestMillis: Int64 = 0
    var receivedResponseMillis: Int64 = 0

    public init(request: Request, cacheResponse: Option<Response>) {
        this.request = request
        this.cacheResponse = cacheResponse

        if (has(cacheResponse)) {
            let cacheRes = cacheResponse.getOrThrow()
            this.sentRequestMillis = cacheRes.sentRequestAtMillis()
            this.receivedResponseMillis = cacheRes.receivedResponseAtMillis()
            let headers: Header = cacheResponse.getHeaders()
            for ((k,v) in headers) {
                let value = v[0]
                if(equalsIgnoreCase("Date", k)) {
                    servedDate = CookieUtil.parseExpires(value, 0, value.length)
                } else if (equalsIgnoreCase("Expires", k)) {
                    expires = CookieUtil.parseExpires(value, 0, value.length)
                } else if (equalsIgnoreCase("Last-Modified", k)) {
                    lastModified = CookieUtil.parseExpires(value, 0, value.length)
                    lastModifiedString = value
                } else if (equalsIgnoreCase("ETag", k)) {
                    etag = value
                } else if (equalsIgnoreCase("Age", k)) {
                    ageSeconds =  Util.parseSeconds(value, -1)
                }

            }
        }

    }

    public func get(): CacheStrategy{
        let candidate: CacheStrategy = getCandidate()

        if (has(candidate.networkRequest) && request.getCacheControl().onlyIfCached()) {
             return CacheStrategy(Option<Request>.None, Option<Response>.None)
        }

        return candidate
    }

    private func getCandidate() {
        if (!has(cacheResponse)) {
             return CacheStrategy(request, Option<Response>.None)
        }

        if (!isCacheable(cacheResponse.getOrThrow(), request)) {
            return CacheStrategy(request, Option<Response>.None)
        }

        let responseCaching: CacheControl = cacheResponse.getOrThrow().getCacheControl()
        let ageMillis = cacheResponseAge()
        var freshMillis = computeFreshnessLifetime()

        if (requestCaching.maxAgeSeconds() != -1) {
            freshMillis = min(freshMillis, requestCaching.maxAgeSeconds()*1000)
        }

        var minFreshMillis = 0
        if (requestCaching.minFreshSeconds() != -1) {
            minFreshMillis = requestCaching.minFreshSeconds()
        }

        var maxStaleMillis = 0

        if(!responseCaching.mustRevalidate() && requestCaching.maxStaleSeconds() != -1) {
            maxStaleMillis = requestCaching.maxStaleSeconds()*1000
        }

        if(!responseCaching.noCache() && ageMillis + minFreshMillis < freshMillis + maxStaleMillis) {
            let builder: ResponseBuilder  = cacheResponse.newBuilder()
            builder.addHeader("Warning", "110 HttpURLConnection \"Response is stale\"")
            var oneDayMillis = 24 * 60 * 60 * 1000
            if(ageMillis > oneDayMillis && isFreshnessLifetimeHeuristic()) {
                builder.addHeader("Warning", "113 HttpURLConnection \"Heuristic expiration\"")
            }
            return CacheStrategy(Option<Request>.None, builder.build())
        }
        var conditionName: String
        var conditionValue: String

        if (etag != "") {
            conditionName = "If-None-Match"
            conditionValue = etag
        } else if (has(lastModified)) {
            conditionName = "If-Modified-Since"
            conditionValue = lastModifiedString
        } else if (has(servedDate)) {
            conditionName = "If-Modified-Since"
            conditionValue = servedDateString
        } else {
            return CacheStrategy(request, Option<Response>.None)
        }
        let conditionalRequestHeaders = response.getHeaders().clone()
        conditionalRequestHeaders.add(conditionName, conditionValue.trim())

        var conditionalRequest =  request.newBuilder().headers(conditionalRequestHeaders).build()
        return CacheStrategy(conditionalRequest, cacheResponse)
    }


    private func isFreshnessLifetimeHeuristic(): Bool {
        return cacheResponse.cacheControl().maxAgeSeconds() == -1 && !has(expires)
    }

    private func computeFreshnessLifetime() {
        let responseCaching: CacheControl = cacheResponse.getOrThrow().getCacheControl()
        if (responseCaching.getMaxAgeSeconds() != -1) {
            return responseCaching.getMaxAgeSeconds() * 1000
        } else if (has(expires)) {

            let servedMillis = match(servedDate) {
                case Some(v) => return getTimeStamp(v)
                case None => return receivedResponseMillis
            }
            var delta = getTimeStamp(expires.getOrThrow()) - servedMillis

            if (delta < 0) {
                delta = 0
            }
            return delta
        } else if (has(lastModified) && cacheResponse.getRequest().getUrl().rawQuery() != "") {
             let servedMillis = match(servedDate) {
                case Some(v) => return getTimeStamp(v)
                case None => return sentRequestMillis
             }
             var delta = servedMillis - getTimeStamp(lastModified.getOrThrow())

             if (delta < 0) {
                 delta = 0
             }
             return delta / 10
        }
        return 0

    }

    private func cacheResponseAge(): Int64 {
        let apparentReceivedAge = match(servedDate) {
            case Some(v) => return max(0,receivedResponseMillis - getTimeStamp(v))
            case None => 0
        }

        let receivedAge = if (ageSeconds != -1) {
            return max(apparentReceivedAge, ageSeconds*1000)
        } else {
            return apparentReceivedAge
        }
        let responseDuration = receivedResponseMillis - sentRequestMillis
        let residentDuration = nowMillis - receivedResponseMillis
        return receivedAge + responseDuration + residentDuration
    }

}

func isCacheable(response: Response, request: Request) {
    match (response.getCode()) {
        case 200 | 203 | 204 | 300 | 301 | 308 | 404 | 405 | 410 | 414 | 501  => ()
        case 302 | 307 =>
            if (response.getHeader("Expires", "") != ""
                || response.getCacheControl().maxAgeSeconds() != -1
                || response.getCacheControl().isPublic()
                || response.getCacheControl().isPrivate()) {

            } else {
                return false
            }
        case _ => return false

    }
    return !response.getCacheControl().noStore() && !request.cacheControl().noStore()

}

public class CacheStrategy {
    public let networkRequest: Option<Request>
    public let cacheResponse: Option<Response>

    init (networkRequest: Option<Request>, cacheResponse: Option<Response>) {
        this.networkRequest = networkRequest
        this.cacheResponse = cacheResponse
    }

}