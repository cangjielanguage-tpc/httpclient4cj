/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the RequestLine class.
 */
package okhttp


public class RequestLine {

    public static func get(request: Request): String {
        let result: StringBuilder = StringBuilder()
        result.append(request.getMethod()).append(' ')
        result.appendFromUtf8(request.getUrl().requestURI().toUtf8Array())
        result.append(" HTTP/1.1")
        return result.toString()
    }


}