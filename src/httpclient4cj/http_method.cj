/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

package httpclient4cj

func invalidatesCache(method: String): Bool {
    return method.equals("POST") || method.equals("PUT") || method.equals("PATCH") || method.equals("DELETE") ||
        method.equals("MOVE")
}

func permitsRequestBody(method: String): Bool {
    return method != "GET" && method != "HEAD"
}

func requiresRequestBody(method: String): Bool {
    return method.equals("POST") || method.equals("PUT") || method.equals("PATCH") || method.equals("PROPPATCH") ||
        method.equals("REPORT")
}

func redirectsToGet(method: String): Bool {
    // All requests but PROPFIND should redirect to a GET request.
    return !method.equals("PROPFIND")
}
