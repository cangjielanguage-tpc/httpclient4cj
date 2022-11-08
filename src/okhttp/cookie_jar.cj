/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the CookieJar interface.
 */
package okhttp

from net import http.CookieJar as HttpCookieJar

public interface CookieJar {

    func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit

    func loadForRequest(url: URL): Array<Cookie>
}

class NoCookieJar <: CookieJar {

    public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit {}

    public func loadForRequest(url: URL): Array<Cookie> {
        return Array<Cookie>()
    }
}


class SimpleCookieJar <: CookieJar {
    private let delegate: HttpCookieJar = HttpCookieJar()

    public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit {
        delegate.setCookies(url, cookies)
    }

    public func loadForRequest(url: URL): Array<Cookie> {
        return delegate.cookies(url)
    }
}

public func getSimpleCookieJar(): CookieJar {
    return SimpleCookieJar()
}
