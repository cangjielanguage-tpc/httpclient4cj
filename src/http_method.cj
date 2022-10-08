/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

package okhttp

public func permitsRequestBody(method: String): Bool {
    return method != "GET" && method != "HEAD"
}

public func redirectsWithBody(method: String): Bool {
    // (WebDAV) redirects should also maintain the request body
    return method.equals("PROPFIND")
}

public func redirectsToGet(method: String): Bool {
      // All requests but PROPFIND should redirect to a GET request.
    return !method.equals("PROPFIND")
}