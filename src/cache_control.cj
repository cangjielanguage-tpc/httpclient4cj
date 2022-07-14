/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the CacheControl class.
 */

package okhttp
from std import math.*
from net import http.*
from std import collection.*

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
        .maxStale(Duration.second(Int64(MaxInt32)))
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

    public init(builder: CacheControlBuilder){
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

    /**
     * The Function is parse
     *
     * @param header of Header
     *
     * @return Type of CacheControl
     * @since 0.30.4
     */
    public static func parse(header: Header): CacheControl {
       var noCache: Bool = true    
        var noStore: Bool = true        
        var maxAgeSeconds: Int32 = 0        
        var sMaxAgeSeconds: Int32 = 0       
        var isPrivate: Bool = true       
        var isPublic: Bool = true        
        var mustRevalidate: Bool = true        
        var maxStaleSeconds: Int32 = 0       
        var minFreshSeconds: Int32 = 0        
        var onlyIfCached: Bool = true        
        var noTransform: Bool = true       
        var immutable: Bool = true
        var canUseHeaderValue: Bool = true
        var headerValue: String = ""

        var ss: StringStream = StringStream("")
        header.write(ss)
        let nameAndValue: Array<String> = ss.toString().split("\r\n")
        var head: ArrayList<String> = ArrayList<String>()
        let headers: ArrayList<String> = ArrayList<String>()
        head.appendAll(nameAndValue)
        head.remove(nameAndValue.size() - 1)
        
        for(i in head){
            let c: Array<String> = i.split(":")
            headers.appendAll(c)
        }

        var index: Int64 = 0
        for(i in 0..headers.size()/2) {
            index++  
            let name: String = headers[i * 2]
            let value: String = headers[i * 2 + 1]  
            if (name.toLower().equals("cache-control")) {
                if (!headerValue.isEmpty()) {
                    // Multiple cache-control headers means we can't use the raw value.
                    canUseHeaderValue = false
                } else {
                    headerValue = value
                }
            } else if (name.toLower().equals("pragma")) {
                // Might specify additional cache-control params. We invalidate just in case.
                canUseHeaderValue = false
            } else {
                continue
            }

            var pos: Int64 = 0
            while(pos < value.size()) {
                let tokenStart: Int64 = pos
                pos = Int64(Util.skipUntil(value, Int32(pos), "=,;"))
                let directive: String = value.substring(tokenStart, pos - tokenStart).trim()
                var parameter: String = ""

                if (pos == value.size() || value.charAt(pos) == ',' || value.charAt(pos) == ';') {
                    pos++ // consume ',' or ';' (if necessary)
                    parameter = ""
                } else {
                    pos++ // consume '='
                    pos = Int64(Util.skipWhitespace(value, Int32(pos)))

                    // quoted string
                    if (pos < value.size() && value.charAt(pos) == '\"') {
                        pos++ // consume '"' open quote
                        let parameterStart: Int64 = pos
                        pos = Int64(Util.skipUntil(value, Int32(pos), "\""))
                        parameter = value.substring(parameterStart, pos - parameterStart)
                        pos++ // consume '"' close quote (if necessary)

                        // unquoted string
                    } else {
                        let parameterStart: Int64 = pos   
                        pos = Int64(Util.skipUntil(value, Int32(pos), ",;"))
                        parameter = value.substring(parameterStart, pos - parameterStart).trim()
                    }
                }

                if ("no-cache".toLower().equals(directive)) {
                    noCache = true
                } else if ("no-store".toLower().equals(directive)) {
                    noStore = true
                } else if ("max-age".toLower().equals(directive)) {
                    maxAgeSeconds = Util.parseSeconds(parameter, -1)
                } else if ("s-maxage".toLower().equals(directive)) {
                    sMaxAgeSeconds = Util.parseSeconds(parameter, -1)
                } else if ("private".toLower().equals(directive)) {
                    isPrivate = true
                } else if ("public".toLower().equals(directive)) {
                    isPublic = true
                } else if ("must-revalidate".toLower().equals(directive)) {
                    mustRevalidate = true
                } else if ("max-stale".toLower().equals(directive)) {
                    maxStaleSeconds = Util.parseSeconds(parameter, MaxInt32)
                } else if ("min-fresh".toLower().equals(directive)) {
                    minFreshSeconds = Util.parseSeconds(parameter, -1)
                } else if ("only-if-cached".toLower().equals(directive)) {
                    onlyIfCached = true
                } else if ("no-transform".toLower().equals(directive)) {
                    noTransform = true
                } else if ("immutable".toLower().equals(directive)) {
                    immutable = true
                }
            }
        }

        if (!canUseHeaderValue) {
            headerValue = ""
        }

        return CacheControl(noCache, noStore, maxAgeSeconds, sMaxAgeSeconds, isPrivate, isPublic,
        mustRevalidate, maxStaleSeconds, minFreshSeconds, onlyIfCached, noTransform, immutable,
        headerValue)
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     * @since 0.30.4
     */
    public func toString(): String {
        let result: String = headerValue
        if(result != "") { 
           return result 
        } else { 
            headerValue = headerValueFunc()
            return  headerValue
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
        if (result.size() == 0) { return "" }
        result.remove(result.size() - 2, 1)
        return result.toString()
    }
}




