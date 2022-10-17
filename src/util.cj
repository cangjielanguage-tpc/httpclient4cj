/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Util class.
 */
package okhttp

from std import convert.*
from std import math.*


let METHOD_GET = "GET"

/**
 * The class is Util
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Util {
    private static let VERIFY_AS_IP_ADDRESS = "([0-9a-fA-F]*:[0-9a-fA-F:.]*)|([\\d.]+)"

    /**
     * The Function is closeQuietly
     *
     * @param socket of Option<Socket>
     * @since 0.29.3
     */
    public static func closeQuietly <T> (socket: Option<T>): Unit where T<: Resource{
        match(socket) {
            case Some(s) =>
                try {
                    s.close()
                } catch (ignored: Exception) {
                    throw ignored
                }
            case None => ()
        }
    }

    /**
     * The Function is sameConnection
     *
     * @param a of URL
     * @param b of URL
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public static func sameConnection( a: URL, b: URL): Bool {
        return a.host == b.host
            && a.port() == b.port()
            && a.scheme == b.scheme
    }


    /**
     * The Function is getRequestMethod
     *
     * @param method of String
     *
     * @return Type of RequestMethod
     * @since 0.29.3
     */
    public static func getRequestMethod(method: String): RequestMethod {
        match (method) {
            case "GET" => GET
            case "PUT" => PUT
            case "POST" => POST
            case "HEAD" => HEAD
            case "PATCH" => PATCH
            case "TRACE" => TRACE
            case "DELETE" => DELETE
            case "CONNECT" => CONNECT
            case "OPTIONS" => OPTIONS
            case _ => throw Exception("no such method")
        }

    }

    public static func skipUntil(input: String, pos: Int32, characters: String): Int32 {
        var posi: Int64 = Int64(pos)

        while (posi < input.size) {
            posi++
            let res: Int64 = characters.indexOf(input.charAt(Int64(posi))) ?? -1
            if (res != -1) {
                break
            }
        }

        return Int32(posi)
    }

    public static func skipWhitespace(input: String, pos: Int32): Int32 {
        var posi: Int32 = pos

        while (posi < Int32(input.size)) {
            posi++
            let c: Char = input.charAt(Int64(posi))
            if (UInt32(c) != UInt32(' ') && UInt32(c) != UInt32('\t')) {
                break
            }
        }

        return posi-1
    }

    public static func parseSeconds(value: String, defaultValue: Int32): Int32 {
        try {
            let seconds: Int32 = parseInt32(value).getOrThrow()
            if (seconds > Int32.Max) {
                return Int32.Max
            } else if (seconds < 0) {
                return 0
            } else {
                return seconds
            }
        } catch (e: Exception) {
            return defaultValue
        }
    }

    public static func verifyAsIpAddress(host: String): Bool {

        match(Regex(VERIFY_AS_IP_ADDRESS).matches(host)) {
            case Some(v) => return true
            case None => return false
        }
    }
}

/*
 * The Function is receiveHeaders
 *
 * @param cookieJar of CookieJar
 * @param url of URL
 * @param header of Header
 *
 * @return Type of Unit
 * @since 0.29.3
 */
public func receiveHeaders(cookieJar: CookieJar, url: URL, headers: Header): Unit {
    match(cookieJar) {
        case noCookie: NoCookieJar => return ()
        case _ => ()
    }

    let cookies: ArrayList<Cookie> = CookieUtil.parseAll(url, headers)

    if (cookies.isEmpty()) {
        return ()
    }
    cookieJar.saveFromResponse(url, cookies.toArray())
}

public func disCard(source: Source): Bool {
    try{
        let arr = ByteArrayStream()
        while (source.read(arr, 4096) != -1) {}
        return true
    }catch (e: SocketTimeoutException) {
        return false
    }
}

func equalsIgnoreCase(left: String, right: String): Bool {
    return left.toUpper() == right.toUpper()
}

/**
 * The Function is toArray
 *
 * @param a of ArrayList<String>
 *
 * @return Type of Array<String>
 * @since 0.29.3
 */
public func toArray(a: Array<UInt8>) : Array<Char> {
    var buf2 = Array<Char>(a.size, item: '0')

    for (i in 0..buf2.size) {
        buf2[i] = Char(UInt32(a[i]))
    }
    return buf2
}

func UInt64ToHexString(n: UInt64): Array<Byte> {
    var num: UInt64 = n
    var arrSize: Int64 = 0

    for (i in 0..16) {
        if (num > 0) {
            arrSize++
            num = num >> 4
        } else {
            break
        }
    }

    var arr = Array<Byte>(arrSize, item: UInt8(CHAR_ZERO))
    var mask: UInt64 = 0x0f
    var idx = 0
    num = n

    for (i in arrSize-1..-1:-1) {
        if (num > 0) {
            var item = num & mask
            arr[i] = UInt64ToHex[Int64(item)]
            num = num >>4
        } else {
            break
        }
    }
    return arr
}

func HexStringToUInt64(arr: Array<Byte>): Option<UInt64> {
    var arrSize = arr.size
    var num: UInt64 = 0

    for (i in 0..arrSize) {
        var b = arr[i]
        if (b'0' <= b && b <= b'9') {
            b = b - b'0'
        } else if (b'a' <= b && b <= b'f') {
            b = b - (b'a' - 10)
        } else if (b'A' <= b && b <= b'F') {
            b = b - (b'A' - 10)
        } else {
            return None
        }
        num = num * 16 + UInt64(b)
    }
    return Some(num)
}

func has<T>(op: Option<T>): Bool {
    match(op) {
        case Some(v) => return true
        case None => return false
    }
}