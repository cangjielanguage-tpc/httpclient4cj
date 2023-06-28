/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the RequestLine class.
 */
package okhttp


class RequestLine {

    public static func get(request: Request): String {
        let result: StringBuilder = StringBuilder()
        result.append(request.getMethod()).append(' ')
        let u = request.getUrl()
        let rawPath = if(u.rawPath.size > 0){
            u.rawPath
        }else{
            "/"
        }
        let rawQuery = match(u.rawQuery){
            case Some(v) => "?${v}"
            case _ => ""
        }
        let arr = "${rawPath}${rawQuery}".toUtf8Array()
        result.appendFromUtf8(arr)
        result.append(" HTTP/1.1")
        return result.toString()
    }


}