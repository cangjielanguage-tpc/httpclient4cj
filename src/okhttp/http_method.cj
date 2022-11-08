/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

package okhttp

public func permitsRequestBody(method: String): Bool {
    return method != "GET" && method != "HEAD"
}

public func requiresRequestBody(method: String): Bool {
    return method.equals("POST") || method.equals("PUT") || method.equals("PATCH") || method.equals("PROPPATCH")
         || method.equals("REPORT")
}


public func redirectsToGet(method: String): Bool {
      // All requests but PROPFIND should redirect to a GET request.
    return !method.equals("PROPFIND")
}