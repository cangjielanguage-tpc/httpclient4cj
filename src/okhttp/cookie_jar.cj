/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the CookieJar impls.
 */
package okhttp

from net import http.CookieJar as HttpCookieJar


/**
 * The class NoCookieJar
 *
 * Use no Cookie, this is the default jar in okhttpClient
 *
 * @author luoyukai4
 * @since 0.34.3
 */
class NoCookieJar <: CookieJar {

    /**
     * The Function is saveFromResponse
     *
     * @param url of URL
     * @param cookies of Array<Cookie>
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit {}

    /**
     * The Function is loadForRequest
     *
     * @param url of URL
     *
     * @return Type of Array<Cookie>
     * @since 0.34.3
     */
    public func loadForRequest(url: URL): Array<Cookie> {
        return Array<Cookie>()
    }
}

/**
 * The class SimpleCookieJar
 *
 * provide a SimpleCookieJar for users to use Cookie
 * save the Cookies on memory and then also read them from memory
 * it has no Persistence
 *
 * @author luoyukai4
 * @since 0.34.3
 */
class SimpleCookieJar <: CookieJar {
    /* let member delegate type is HttpCookieJar */
    private let delegate: HttpCookieJar = HttpCookieJar()

    public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit {
        delegate.setCookies(url, cookies)
    }

    /**
     * The Function is loadForRequest
     *
     * @param url of URL
     *
     * @return Type of Array<Cookie>
     * @since 0.34.3
     */
    public func loadForRequest(url: URL): Array<Cookie> {
        return delegate.cookies(url)
    }
}

/**
 * The Function is getSimpleCookieJar
 *
 * @return Type of CookieJar
 * @since 0.34.3
 */
public func getSimpleCookieJar(): CookieJar {
    return SimpleCookieJar()
}
