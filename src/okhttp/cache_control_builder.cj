/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the CacheControlBuilder class.
 */

package okhttp

from std import math.*

/**
 * Builds a CacheControl request header.
 * @author guo_tingtingtekla
 * @since 0.30.4
 */
public class CacheControlBuilder <: Builder<CacheControl> {
    public var noCacheBuild: Bool = true
    
    public var noStoreBuild: Bool = true
    
    public var maxAgeSeconds: Int32 = -1
    
    public var maxStaleSeconds: Int32 = -1
    
    public var minFreshSeconds: Int32 = -1
    
    public var onlyIfCachedBuild: Bool = true
    
    public var noTransformBuild: Bool = true
    
    public var immutableBuild: Bool = true
    
    /**
     * Do not use cache, all go online
     * 
     * @return CacheControlBuilder
     */
    public func noCache(): CacheControlBuilder {
        this.noCacheBuild = true
        return this
    }

    /**
     * Do not use cache and do not store cache
     * 
     * @return CacheControlBuilder
     */
    public func noStore(): CacheControlBuilder {
        this.noStoreBuild = true
        return this
    }

    /**
     * Sets the maximum age of a cached response. If the cache response is age exceeds 
     * maxAge, it will not be used and a network request will be made.
     *
     * @param maxAge a non-negative integer
     * @param TimeUnit of Duration
     * 
     * @return CacheControlBuilder
     */
    public func maxAge(timeUnit: Duration): CacheControlBuilder {
        let maxAgeSecondsLong: Int64 = timeUnit.seconds()
        this.maxAgeSeconds = if ( maxAgeSecondsLong >  Int64(Int32.Max) ) { Int32.Max } else { Int32(maxAgeSecondsLong) }
        return this
    }

    /**
     * Accept cached responses that have exceeded their freshness lifetime by up to 
     * maxStale. If unspecified, stale cache responses will not be used.
     *
     * @param maxStale a non-negative integer
     * @param TimeUnit of Duration
     * 
     * @return CacheControlBuilder
     */
    public func maxStale(timeUnit: Duration): CacheControlBuilder {
        let maxStaleSecondsLong: Int64 = timeUnit.seconds()
        this.maxStaleSeconds = if ( maxStaleSecondsLong >  Int64(Int32.Max) ) {Int32.Max } else { Int32(maxStaleSecondsLong) }
        return this
    }

    /**
     * Sets the minimum number of seconds that a response will continue to be fresh for. If the
     * response will be stale when  minFresh have elapsed, the cached response will not be
     * used and a network request will be made.
     *
     * @param minFresh a non-negative integer
     * @param TimeUnit of Duration
     * 
     * @return CacheControlBuilder
     */
    public func minFresh(timeUnit: Duration): CacheControlBuilder {
        let minFreshSecondsLong: Int64 = timeUnit.seconds()
        this.maxStaleSeconds = if ( minFreshSecondsLong >  Int64(Int32.Max) ) {Int32.Max } else { Int32(minFreshSecondsLong) }
        return this
    }

    /**
     * Only accept the response if it is in the cache. If the response is not cached, a {@code 504
     * Unsatisfiable Request} response will be returned.
     * 
     * @return CacheControlBuilder
     */
    public func onlyIfCached(): CacheControlBuilder {
        this.onlyIfCachedBuild = true
        return this
    }

    /**
     * Do not accept a transformed response, no transcoding
     * 
     * @return CacheControlBuilder
     */
    public func noTransform(): CacheControlBuilder {
        this.noTransformBuild = true
        return this
    }

    /**
     * The Function is immutable
     *
     * @return Type of CacheControlBuilder
     * @since 0.30.4
     */
    public func immutable(): CacheControlBuilder {
        this.immutableBuild = true
        return this
    }

    public func build(): CacheControl {
        return CacheControl(this)
    }
}

