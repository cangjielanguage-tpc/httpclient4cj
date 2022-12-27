/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the CacheControl class.
 */

package okhttp
from std import unicode.*

/**
 * The class is CacheControl
 * @author guo_tingtingtekla
 * @since 0.30.4
 */
public class CacheControl {
    /**
     * Cache control request directives that require network validation of responses. Note that such
     * requests may be assisted by the cache via conditional GET requests.
     */
    public static let FORCE_NETWORK: CacheControl = CacheControlBuilder().noCache().build()
    
    /**
     * Cache control request directives that uses the cache only, even if the cached response is
     * stale. If the response is not available in the cache or requires server validation, the call
     * will fail with a {@code 504 Unsatisfiable Request}.
     */
    public static let FORCE_CACHE: CacheControl = CacheControlBuilder()
        .onlyIfCached()
        .maxStale(Duration.second(Int64(Int32.Max)))
        .build()
       
    private var noCacheInit: Bool = true
    
    private var noStoreInit: Bool = true
    
    private var maxAgeSecondsInit: Int32 = 0
    
    private var sMaxAgeSecondsInit: Int32 = 0
    
    private var isPrivateInit: Bool = true
    
    private var isPublicInit: Bool = true
    
    private var mustRevalidateInit: Bool = true
    
    private var maxStaleSecondsInit: Int32 = 0
    
    private var minFreshSecondsInit: Int32 = 0
    
    private var onlyIfCachedInit: Bool = true
    
    private var noTransformInit: Bool = true
    
    private var immutableInit: Bool = true

    private static let NO_CACHE: String = "no-cache"
    private static let NO_STORE: String = "no-store"
    private static let MAX_AGE: String = "max-age"
    private static let S_MAXAGE: String = "s-maxage"
    private static let PUBLIC: String = "public"
    private static let PRIVATE: String = "private"
    private static let MUST_REVALIDATE: String = "must-revalidate"
    private static let MAX_STALE: String = "max-stale"
    private static let MIN_FRESH: String = "min-fresh"
    private static let ONLY_IF_CACHED: String = "only-if-cached"
    private static let NO_TRANSFORM: String = "no-transform"
    private static let IMMUTABLE: String = "immutable"

    // Lazily computed, null if absent
    var headerValue: String = ""

    private init (noCache: Bool, noStore: Bool, maxAgeSeconds: Int32, 
                    sMaxAgeSeconds: Int32, isPrivate: Bool, isPublic: Bool, 
                    mustRevalidate: Bool, maxStaleSeconds: Int32, minFreshSeconds: Int32, 
                    onlyIfCached: Bool, noTransform: Bool, immutable: Bool, headerValue: String)
    {
        this.noCacheInit = noCache
        this.noStoreInit = noStore
        this.maxAgeSecondsInit = maxAgeSeconds
        this.sMaxAgeSecondsInit = sMaxAgeSeconds
        this.isPrivateInit = isPrivate
        this.isPublicInit = isPublic
        this.mustRevalidateInit = mustRevalidate
        this.maxStaleSecondsInit = maxStaleSeconds
        this.minFreshSecondsInit = minFreshSeconds
        this.onlyIfCachedInit = onlyIfCached
        this.noTransformInit = noTransform
        this.immutableInit = immutable
        this.headerValue = headerValue 
    }

    public init(builder: CacheControlBuilder) {
        this.noCacheInit = builder.noCacheBuild
        this.noStoreInit = builder.noStoreBuild
        this.maxAgeSecondsInit = builder.maxAgeSeconds
        this.sMaxAgeSecondsInit = -1
        this.isPrivateInit = false
        this.isPublicInit = false
        this.mustRevalidateInit = false
        this.maxStaleSecondsInit = builder.maxStaleSeconds
        this.minFreshSecondsInit = builder.minFreshSeconds
        this.onlyIfCachedInit = builder.onlyIfCachedBuild
        this.noTransformInit = builder.noTransformBuild
        this.immutableInit = builder.immutableBuild
    }
    
    
    public static func builder(): CacheControlBuilder {
        return CacheControlBuilder()
    }

    /**
     * In a response, this field is name "no-cache" is misleading. It does not prevent us from caching
     * the response it only means we have to validate the response with the origin server before
     * returning it. We can do this with a conditional GET.
     *
     * <p>In a request, it means do not use a cache to satisfy the request.
     *
     * @return Bool
     */
    public func noCache(): Bool {
        return noCacheInit
    }

    /**
     * If true, this response should not be cached.
     *
     * @return Bool
     */
    public func noStore(): Bool {
        return noStoreInit
    }

    /**
     * The duration past the response is served date that it can be served without validation.
     *
     * @return Int64
     */
    public func maxAgeSeconds(): Int32 {
        return maxAgeSecondsInit
    }

    /**
     * The "s-maxage" directive is the max age for shared caches. Not to be confused with "max-age"
     * for non-shared caches, As in Firefox and Chrome, this directive is not honored by this cache.
     *
     * @return Int64
     */
    public func sMaxAgeSeconds(): Int32 {
        return sMaxAgeSecondsInit
    }

    /**
     * The Function is isPrivate
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func isPrivate(): Bool {
        return isPrivateInit
    }

    /**
     * The Function is isPublic
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func isPublic(): Bool {
        return isPublicInit
    }

    /**
     * The Function is mustRevalidate
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func mustRevalidate(): Bool {
        return mustRevalidateInit
    }

    /**
     * The Function is maxStaleSeconds
     *
     * @return Type of Int32
     * @since 0.30.4
     */
    public func maxStaleSeconds(): Int32 {
        return maxStaleSecondsInit
    }

    /**
     * The Function is minFreshSeconds
     *
     * @return Type of Int32
     * @since 0.30.4
     */
    public func minFreshSeconds(): Int32 {
        return minFreshSecondsInit
    }

    /**
     * The Function is onlyIfCached
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func onlyIfCached(): Bool {
        return onlyIfCachedInit
    }

    /**
     * The Function is noTransform
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func noTransform(): Bool {
        return noTransformInit
    }

    /**
     * The Function is immutable
     *
     * @return Type of Bool
     * @since 0.30.4
     */
    public func immutable(): Bool {
        return immutableInit
    }

    private static func makeNameValues(header: Header): ArrayList<String> {
        var ss: ByteArrayStream = ByteArrayStream()
        header.writeTo(ss)
        let nameAndValue: Array<String> = String.fromUtf8(ss.readToEnd()).split("\r\n")
        let nvSize = nameAndValue.size
        var head: ArrayList<String> = ArrayList<String>()

        for (i in 0..nvSize-1) {
            head.append(nameAndValue[i])
        }

        let headers: ArrayList<String> = ArrayList<String>()

        for (i in head) {
            let c: Array<String> = i.split(":")
            headers.appendAll(c)
        }
        return headers
    }

    /**
     * The Function is parse
     *
     * @param header of Header
     *
     * @return Type of CacheControl
     * @since 0.30.4
     */
    public static func parse(header: Header): CacheControl {
        let map: HashMap<String,String> =  HashMap<String,String>()
        map.put(NO_CACHE, "false")
        map.put(NO_STORE, "false")
        map.put(MAX_AGE, "-1")
        map.put(S_MAXAGE, "-1")
        map.put(PUBLIC, "false")
        map.put(PRIVATE, "false")
        map.put(MUST_REVALIDATE, "false")
        map.put(MAX_STALE, "-1")
        map.put(MIN_FRESH, "-1")
        map.put(ONLY_IF_CACHED, "false")
        map.put(NO_TRANSFORM, "false")
        map.put(IMMUTABLE, "false")
        let headerValue: String = parseNameValues(header, map)
        return CacheControl(Bool.parse(map[NO_CACHE]), Bool.parse(map[NO_STORE]), Int32.parse(map[MAX_AGE]),
            Int32.parse(map[S_MAXAGE]), Bool.parse(map[PRIVATE]), Bool.parse(map[PUBLIC]),
            Bool.parse(map[MUST_REVALIDATE]), Int32.parse(map[MAX_STALE]), Int32.parse(map[MIN_FRESH]),
            Bool.parse(map[ONLY_IF_CACHED]), Bool.parse(map[NO_TRANSFORM]), Bool.parse(map[IMMUTABLE]),
            headerValue.trim())
    }

    private static func parseNameValues(header: Header, map: HashMap<String,String>): String {
        let headers: ArrayList<String> = makeNameValues(header)
        var headerValue: String = ""
        var canUseHeaderValue: Bool = true
        var index: Int64 = 0

        for (i in 0..headers.size/2) {
            index++
            let name: String = headers[i * 2]
            let value: String = headers[i * 2 + 1]
            if (name.toLower().equals("cache-control")) {
                if (!headerValue.isEmpty()) {
                    canUseHeaderValue = false
                } else {
                    headerValue = value
                }
            } else if (name.toLower().equals("pragma")) {
                canUseHeaderValue = false
            } else {
                continue
            }
            var pos: Int64 = 0
            while (pos < value.size) {
                let tokenStart: Int64 = pos
                pos = Int64(Util.skipUntil(value, Int32(pos), "=,;"))
                let directive: String = value.substring(tokenStart, pos - tokenStart).trim()
                var parameter: String = ""
                if (pos == value.size || value.charAt(pos) == ',' || value.charAt(pos) == ';') {
                    pos++ // consume ',' or ';' (if necessary)
                    parameter = ""
                } else {
                    pos++ // consume '='
                    pos = Int64(Util.skipWhitespace(value, Int32(pos)))
                    if (pos < value.size && value.charAt(pos) == '\"') {
                        pos++ // consume '"' open quote
                        let parameterStart: Int64 = pos
                        pos = Int64(Util.skipUntil(value, Int32(pos), "\""))
                        parameter = value.substring(parameterStart, pos - parameterStart)
                        pos++ // consume '"' close quote (if necessary)
                    } else {
                        let parameterStart: Int64 = pos
                        pos = Int64(Util.skipUntil(value, Int32(pos), ",;"))
                        parameter = value.substring(parameterStart, pos - parameterStart).trim()
                    }
                }
               parseDirective(directive, map, parameter)
               if (!canUseHeaderValue) {
                   headerValue = ""
               }
            }
        }
        return headerValue
    }

    private static func parseDirective (directive: String, map: HashMap<String,String>, parameter: String): Unit {
        match (directive.toLower()) {
            case "no-cache" => map.put(NO_CACHE, "true")
            case "no-store" => map.put(NO_STORE, "true")
            case "max-age" => map.put(MAX_AGE, "${Util.parseSeconds(parameter, -1)}")
            case "s-maxage" => map.put(S_MAXAGE, "${Util.parseSeconds(parameter, -1)}")
            case "public" =>  map.put(PUBLIC, "true")
            case "private" => map.put(PRIVATE, "true")
            case "must-revalidate" => map.put(MUST_REVALIDATE, "true")
            case "max-stale" =>  map.put(MAX_STALE, "${Util.parseSeconds(parameter, Int32.Max)}")
            case "min-fresh" => map.put(MIN_FRESH, "${Util.parseSeconds(parameter, -1)}")
            case "only-if-cached" => map.put(ONLY_IF_CACHED, "true")
            case "no-transform" => map.put(NO_TRANSFORM, "true")
            case "immutable" => map.put(IMMUTABLE, "true")
            case _ => ()
        }
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     * @since 0.30.4
     */
    public func toString(): String {
        let result: String = headerValue
        if (result != "") {
           return result 
        } else { 
            headerValue = headerValueFunc()
            return headerValue
        }    
    }

    private func headerValueFunc(): String {
        var result: StringBuilder = StringBuilder()
        if (noCacheInit) { result.append("no-cache, ") }
        if (noStoreInit) { result.append("no-store, ") }
        if (maxAgeSecondsInit != -1) { result.append("max-age=").append(maxAgeSecondsInit).append(", ") }
        if (sMaxAgeSecondsInit != -1) { result.append("s-maxage=").append(sMaxAgeSecondsInit).append(", ") }
        if (isPrivateInit) { result.append("private, ") }
        if (isPublicInit) { result.append("public, ") }
        if (mustRevalidateInit) { result.append("must-revalidate, ") }
        if (maxStaleSecondsInit != -1) { result.append("max-stale=").append(maxStaleSecondsInit).append(", ") }
        if (minFreshSecondsInit != -1) { result.append("min-fresh=").append(minFreshSecondsInit).append(", ") }
        if (onlyIfCachedInit) { result.append("only-if-cached, ") }
        if (noTransformInit) { result.append("no-transform, ") }
        if (immutableInit) { result.append("immutable, ") }
        if (result.size == 0) { return "" }
        result.remove(result.size - 2..result.size - 1)
        return result.toString().trim()
    }
}




