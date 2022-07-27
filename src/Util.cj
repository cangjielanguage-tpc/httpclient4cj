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

/**
 * The class is Util
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Util {

    /**
     * The Function is closeQuietly
     *
     * @param socket of Option<Socket>
     * @since 0.29.3
     */
    public static func closeQuietly(socket: Option<Socket>) {
        match(socket) {
            case Some(s) =>{
                try {
                    s.close()
                } catch (rethrown: RuntimeException) {
                    throw rethrown
                } catch (ignored: Exception) {
                    throw ignored
                }
            }
            case None => {}
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
        while(posi < input.size()) {
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
        while(posi < Int32(input.size())) {
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
            if (seconds > MaxInt32) {
                return MaxInt32
            } else if (seconds < 0) {
                return 0
            } else {
                return seconds
            }
        } catch (e: Exception) {
            return defaultValue
        }
    }
}

public enum SocketClient {
    | SocketC(Socket)
    | TlsC(TlsSocket)

    public func connect(): Unit {
        match(this) {
            case SocketC(conn) => conn.connect()
            case TlsC(conn) => ()
        }
    }

    func connect(timeout: Duration): Unit {
        match(this) {
            case SocketC(conn) => conn.connect(timeout)
            case TlsC(conn) => ()
        }
    }

    func read(buffer: Array<Byte>): Option<Int64> {
        return match(this) {
            case SocketC(conn) => conn.read(buffer)
            case TlsC(conn) => conn.read(buffer)
        }
    }

    func read(buffer: Array<Byte>, timeout: Duration): Option<Int64> {
        return match(this) {
            case SocketC(conn) => conn.read(buffer, timeout)
            case TlsC(conn) => conn.read(buffer)
        }
    }

    func write(buffer: Array<Byte>): Option<Int64> {
        return match(this) {
            case SocketC(conn) => conn.write(buffer)
            case TlsC(conn) => conn.write(buffer)
        }
    }

    func write(buffer: Array<Byte>, timeout: Duration): Option<Int64> {
        return match(this) {
            case SocketC(conn) => conn.write(buffer, timeout)
            case TlsC(conn) => conn.write(buffer)
        }
    }

    func close(): Unit {
        return match(this) {
            case SocketC(conn) =>
                conn.close()
            case TlsC(conn) =>
                conn.close()
        }
    }
}
