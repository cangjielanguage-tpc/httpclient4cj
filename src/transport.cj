/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Transport class.
 */
package okhttp

from std import time.*
from std import collection.*
from std import io.*
from std import convert.*
from std import unicode.*
from std import socket.*
from encoding import url.*
from net import http.*

/* let member readLength type is Int64 */
let readLength: Int64 = 4096

/* let member DEFAULT_PROTOCOL_PORT */
let DEFAULT_PROTOCOL_PORT = HashMap<String, String>(
    [("http", "80"),("https", "443"),("socks5", "1080")]
)


/**
 * The class is Transport
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Transport {
    /* var member proxy type is Option<(http.Request) -> URL> */
    var proxy: Option<(http.Request) -> URL> = Option<(http.Request) -> URL>.None

    /** var member tlsHandshakeTimeout type is Duration */
    public var tlsHandshakeTimeout: Duration = Duration.second()

    /* var member maxIdleConns type is Int64 */
    var maxIdleConns: Int64 = 0

    /* var member idleConnTimeout type is Duration */
    var idleConnTimeout: Duration = Duration.second()

    /* var member expectContinueTimeout type is Duration */
    var expectContinueTimeout: Duration = Duration.second()

    /* var member forceAttemptHTTP2 type is Bool */
    var forceAttemptHTTP2: Bool = false

    /* var member overtime type is Time */
    private var overtime: Time = Time.now()

    /* var member clientOverTimeDur type is Option<Duration> */
    private var clientOverTimeDur: Option<Duration> = None

    /*
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    init() {}

    /**
     * The Function is getDefault
     *
     * @return Type of Transport
     * @since 0.29.3
     */
    public static func getDefault(): Transport {
        var defaultTransport = Transport()
        defaultTransport.proxy = Option<(http.Request) -> URL>.None
        defaultTransport.forceAttemptHTTP2 = true
        defaultTransport.maxIdleConns = 100
        defaultTransport.idleConnTimeout = Duration.second(90)
        defaultTransport.tlsHandshakeTimeout = Duration.second(10)
        defaultTransport.expectContinueTimeout = Duration.second(1)
        return defaultTransport
    }

    /**
     * The Function is roundTrip
     *
     * @param req of http.Request
     *
     * @return Type of PersistConn
     * @since 0.29.3
     */
    public func roundTrip(req: http.Request): PersistConn{
        var reqss = req.body as StringStream
        var reqs: String = String(reqss.getOrThrow().getChars())
        var scheme = req.url.scheme
        var isHTTP: Bool = scheme == "http" || scheme == "https"
        if (isHTTP) {
            try {
                req.header.checkHeaderNameVal()
            } catch(e: Exception) {
                closeBody(req, panic: false)
                return PersistConn(Option<Socket>.None)
            }
        }
        if (!isHTTP) {
            closeBody(req, panic: false)
            throw HttpException("unsupported protocol scheme ${scheme}")
        }
        if (!validMethod(req.method.toString())) {
            closeBody(req, panic: false)
            throw HttpException("net/http: invalid method ${req.method.toString()}")
        }
        if (req.url.host == "") {
            closeBody(req, panic: false)
            throw HttpException("http: no Host in request URL")
        }


        match (this.getConn(req)) {
            case Some(conn) =>
                conn.setClientoTimeDuration(clientoTime: this.clientOverTimeDur)
                return conn
            case _ =>
                closeBody(req, panic: false)
        }
        return PersistConn(Option<Socket>.None)
    }

    /*
     * The Function is getConn
     *
     * @param request of http.Request
     *
     * @return Type of Option<PersistConn>
     * @since 0.29.3
     */
    private func getConn(request: http.Request): Option<PersistConn> {
        var host:String = request.url.hostname()
        var port:UInt16 = 80
        match(parseUInt16(request.url.port())){
            case Some(v) => port = v
            case None =>
                if (request.url.toString().startsWith("https")) {
                    port = 443
                } else {
                    port = 80
                }
        }
        var client: Socket = Socket(TCP, host, port)
        client.connect()
        try {
            var pc = PersistConn(Option<Socket>.Some(client))
            return Some(pc)
        } catch (e: Exception) {
            return None
        }

    }

    /**
     * The Function is validMethod
     *
     * @param method of String
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public static func validMethod(method: String): Bool {
        // return method.size() > 0 && indexFunc(method, isNotToken(0)) == -1
        return true
    }

    /*
     * The Function is requiresHTTP1
     *
     * @param r of http.Request
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    private func requiresHTTP1(r: http.Request): Bool {
        var con = match (r.header.get("Connection")) {
            case Some(x) => x
            case None => ""
        }
        var upgrade = match (r.header.get("Upgrade")) {
            case Some(x) => x
            case None => ""
        }
        // return TransferWriter.hasToken(con, "upgrade") && upgrade.toLower().equals("websocket")
        return true
    }

    /*
     * The Function is canonicalAddrs
     *
     * @param url of URL
     *
     * @return Type of String
     * @since 0.29.3
     */
    private func canonicalAddrs(url: URL): String {
        var addr: String = url.hostname()
        var vRes: (String, String) = idnaASCII(addr)
        if (vRes[1] == "") {
            addr = vRes[0]
        }
        var port: String = url.port()
        if (port == "") {
            port = DEFAULT_PROTOCOL_PORT[url.scheme]
        }
        return joinHostPort(addr, port)
    }

    /*
     * The Function is joinHostPort
     *
     * @param host of String
     * @param port of String
     *
     * @return Type of String
     * @since 0.29.3
     */
    private func joinHostPort(host: String, port: String): String {
        var res = match (host.indexOf(":")) {
            case Some(x) => x
            case None => -1
        }
        if (res >= 0) {
            return "[ ${host} ]: ${port}"
        }
        return "${host} : ${port}"
    }

    /*
     * The Function is idnaASCII
     *
     * @param v of String
     *
     * @return Type of (String, String)
     * @since 0.29.3
     */
    private func idnaASCII(v: String): (String, String) {
        if (isASCII(v)) {
            return (v, "")
        }
        return toASCII(v)
    }

    /*
     * The Function is toASCII
     *
     * @param s of String
     *
     * @return Type of (String, String)
     * @since 0.29.3
     */
    private func toASCII(s: String): (String, String) {
        if (isASCII(s)) {
            return (s, "")
        }
        let labels = s.split(".")
        var output = StringStream("")
        for (i in 0..labels.size()) {
            var label = labels[i]
            if (i != 0) {
                output.appends('.')
            }
            if (!isASCII(label)) {
                let res = encode("xn--", label)
                if (!res[1].isEmpty()) {
                    return ("", res[1])
                }
                output.appends(res[0])
            } else {
                output.appends(label)
            }
        }
        return (String(output.getChars()), "")
    }

    /*
     * The Function is encode
     *
     * @param prefix of String
     * @param s of String
     *
     * @return Type of (String, String)
     * @since 0.29.3
     */
    private func encode(prefix: String, s: String): (String, String) {
        var output = StringStream(prefix)
        var b = 0
        var remaining = 0
        var delta = 0
        var n = 128
        var bias = 72
        for (i in 0..s.size()) {
            let c = s[i]
            if (ord(c) < 0x80) {
                output.appends(c)
                b++
            } else {
                remaining++
            }
        }
        var ft = b
        if (b > 0) {
            output.appends('-')
        }
        while (remaining != 0) {
            var m = Int64(0x7fffffff)
            for (i in 0..s.size()) {
                var num = Int64(ord(s[i]))
                if (m > num && num >= n) {
                    m = num
                }
            }
            delta += (m -n) * (ft +1)
            if (delta < 0) {
                return ("", "cookjar: invalid label"+s)
            }
            n = m
            for (i in 0..s.size()) {
                var v = Int64(ord(s[i]))
                if (v < n) {
                    delta++
                    if (delta < 0) {
                        return ("", "cookjar: invalid label"+s)
                    }
                    continue
                }
                if (v > n) {
                    continue
                }
                var q = delta
                var k = 36
                var t = k - bias
                while (q >= t) {
                    if (t < 1) {
                        t = 1
                    } else if (t > 26) {
                        t = 26
                    }
                    output.appends(encodeDigit(t + (q - t) % (36 - t)))
                    q = (q - t) / (36 -t)
                    k += 36
                }
                output.appends(encodeDigit(q))
                bias = adaptcj(delta, ft + 1, b == ft)
                remaining--
                delta = 0
                ft++
            }
            n++
            delta++
        }
        return (String(output.getChars()), "")
    }

    /*
     * The Function is adaptcj
     *
     * @param d of Int64
     * @param n of Int64
     * @param flag of Bool)
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    private func adaptcj(d: Int64, n: Int64, flag: Bool) : Int64 {
        var delta = d
        if (flag) {
            delta /= 700
        } else {
            delta /= 2
        }
        delta += delta / n
        var k = 0
        while (delta > ((36 - 1) * 26) / 2) {
            delta /= 36 -1
            k += 36
        }
        return k + 36 * delta / (delta + 38)
    }

    /*
     * The Function is encodeDigit
     *
     * @param digit of Int64)
     *
     * @return Type of Char
     * @since 0.29.3
     */
    private func encodeDigit (digit: Int64) : Char {
        if (0< digit && digit < 26) {
            return chr(UInt32(digit) + UInt32(ord('a')))
        } else if (26 < digit && digit < 36) {
            return chr(UInt32(digit + Int64(ord('0'))- 26))
        } else {
            throw RuntimeException("encodeDigit error")
        }
    }

    /*
     * The Function is isASCII
     *
     * @param s of String
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    private func isASCII(s: String): Bool {
        for (temp in s) {
            if (Int64(ord(temp)) >= Int64(0x80)) {
                return false
            }
        }
        return true
    }

    /**
     * The Function is setClientOverTimeDur
     *
     * @param durTime of Option<Duration>, and the Default value is None
     * @since 0.29.3
     */
    public func setClientOverTimeDur(durTime!: Option<Duration> = None) {
        this.clientOverTimeDur = durTime
    }
}

/* let member CRLF_CRLF type is Array<Byte> */
let CRLF_CRLF: Array<Byte> = b"\r\n\r\n"
/* let member CRLF type is Array<Byte> */
let CRLF: Array<Byte> = b"\r\n"
/* let member SP */
let SP = b" "
/* let member TRIM_BYTE type is Array<Byte> */
let TRIM_BYTE: Array<Byte> = SP

/**
 * The class is PersistConn
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class PersistConn {
    /* var member client type is Socket */
    private var client: Socket
    /* var member clientoTimeDuration type is Option<Duration> */
    private var clientoTimeDuration: Option<Duration> = None

    /* var member respHead type is Header */
    private var respHead: Header = Header()
    /* var member allBuf type is ByteArrayStream */
    private var allBuf: ByteArrayStream = ByteArrayStream()
    /* var member parsedIndex type is Int64 */
    private var parsedIndex: Int64 = 0
    /* var member isParsingHeader type is Bool */
    private var isParsingHeader: Bool = true
    /* var member isChunked type is Bool */
    private var isChunked: Bool = false

    /* var member proto type is String */
    private var proto: String = String()
    /* var member status type is String */
    private var status: String = String()
    /* var member statusCode type is Int64 */
    private var statusCode: Int64 = 200

    /**
     * The Function is init constructor
     *
     * @param conn of Option<Socket>
     * @since 0.29.3
     */
    public init(conn : Option<Socket>) {
        this.client = match(conn) {
            case None => throw HttpException( "socket connect exception" )
            case Some(v) => v
        }
    }

    /**
     * The Function is roundTripTrans
     *
     * @param request of http.Request
     *
     * @return Type of http.Response
     * @since 0.29.3
     */
    public func roundTripTrans(request: http.Request): http.Response {
        this.execRw(request)
        if (this.allBuf.isEmpty()) {
            throw HttpException("The server socket connection is abnormal.")
        }
        var protoMajor: Int64 = request.protoMajor
        var protoMinor: Int64 = request.protoMajor
        let contentLengthStr = this.respHead.get("Content-Length") ?? "-1"
        var contentLength: Int64 = parseInt64(contentLengthStr.trim()).getOrThrow()
        var body = parseBody(request)
        var trailer: Header = Header()
        var resp = http.Response(this.proto, this.status, this.statusCode, protoMajor, protoMinor, this.respHead, trailer, false,
                            contentLength, body, toArray(request.transferEncoding), request: request)
        return resp
    }

    /**
     * The Function is setClientoTimeDuration
     *
     * @param clientoTime of Option<Duration>, and the Default value is None
     * @since 0.29.3
     */
    public func setClientoTimeDuration(clientoTime!: Option<Duration> = None) {
        this.clientoTimeDuration = clientoTime
    }

    /*
     * The Function is execRw
     *
     * @param request of http.Request
     * @since 0.29.3
     */
    private func execRw(request: http.Request){
        var requestStream: StringStream = StringStream("")
        request.write(requestStream)
        let reqMethod = request.method.toString()
        let writeBuf = requestStream.toString().toUtf8Array()

        match (this.client.write(writeBuf)) {
            case Err(e) => this.client.close()
            case Ok(v) => ()
        }
        var readBuf: Array<Byte> = Array<Byte>(readLength, item: 0)
        var contentLength: Int64 = -1
        var bodyItemIndex = -1
        try {
            while (true) {
                var lenNum: Int64 = this.ReadBytesToBuffer(readBuf)
                if (lenNum <= 0) {
                    break
                }
                this.allBuf.write(readBuf, 0, lenNum)

                if (this.isParsingHeader) {
                    this.parseHead()
                    if (this.isParsingHeader) {
                        continue
                    } else {
                        match (this.respHead.get("Content-Length")) {
                            case Some(s) =>
                            match (parseInt64(s)) {
                                case Some(n) => contentLength = n
                                case None => HttpException("Content-Length is invalid: ${s}.")
                            }
                            case None => contentLength = -1
                        }
                        match (this.respHead.get("Transfer-Encoding")) {
                            case Some(s) =>
                                if (s == "chunked") {
                                    this.isChunked = true
                                }
                            case None => ()
                        }
                        bodyItemIndex = this.parsedIndex
                    }
                }
                if (reqMethod == "HEAD") {
                    break
                }
                if (this.isChunked) {
                    let crlfCrlfIndex = this.allBuf.indexOf(CRLF_CRLF, start: bodyItemIndex)
                    if (bodyItemIndex == this.parsedIndex) {
                        bodyItemIndex -= CRLF_CRLF.size()
                    }
                    match (crlfCrlfIndex) {
                        case Some(x) =>
                            break
                        case None =>
                            bodyItemIndex += lenNum
                            continue
                    }
                } else {
                    if (this.allBuf.size() - this.parsedIndex >= contentLength) {
                        break
                    }
                    continue
                }
            }
        } finally {
            this.client.close()
        }
    }

    /*
     * The Function is ReadBytesToBuffer
     *
     * @param readBuf of Array<Byte>
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    private func ReadBytesToBuffer( readBuf: Array<Byte>): Int64 {
        var lenNum: Int64 = -1
        match(this.clientoTimeDuration){
            case Some(time) =>
                let readTimeLen = this.client.read(readBuf, time)
                match (readTimeLen) {
                    case Ok(v) =>
                        match (v) {
                            case Some(l) =>
                                lenNum = l
                            case None =>
                                throw HttpException("Request Timeout.")
                        }
                    case Err(e) =>
                        throw e
                }
            case None =>
                let readLen = this.client.read(readBuf)
                match (readLen) {
                    case Ok(l) =>
                        lenNum = l
                    case Err(e) =>
                        lenNum = -1
                }
        }
        return lenNum
    }
    /**
     * The Function is parseHead
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func parseHead(): Unit {
        if (this.parsedIndex == 0) {
            var crlfIndex = match(this.allBuf.indexOf(CRLF, start: 0)) {
                case Some(i) =>
                    this.parsedIndex = i+2
                    i
                case None =>
                    return
            }
            var protoEndIndex = match (this.allBuf.indexOf(SP, start: 0)) {
                case Some(i) => i
                case None => throw HttpException("header data is invalid: ")
            }
            var statusCodeEndIndex = match (this.allBuf.indexOf(SP, start: protoEndIndex + 1)) {
                case Some(i) => i
                case None => throw HttpException("header data is invalid: ")
            }
            this.proto = String.fromUtf8(this.allBuf.slice(0, protoEndIndex), isAscii: true)
            this.status = String.fromUtf8(this.allBuf.slice(protoEndIndex+1, crlfIndex - protoEndIndex - 1), isAscii: true)
            if (statusCodeEndIndex > crlfIndex) {
                this.statusCode = match (parseInt64(status)) {
                    case Some(x) => x
                    case None => throw Exception("statusCode is invalid: ${status}")
                }
            } else {
                var itemStr = String.fromUtf8(this.allBuf.slice(protoEndIndex + 1, statusCodeEndIndex - protoEndIndex - 1), isAscii: true)
                this.statusCode = match (parseInt64(itemStr)) {
                    case Some (x) => x
                    case None => throw Exception("statusCode is invalid: ${itemStr}")
                }
            }
        }
        while (true) {
            match (this.allBuf.indexOf(CRLF, start: this.parsedIndex)) {
                case Some(i) =>
                    if (i == this.parsedIndex) {
                        this.isParsingHeader = false
                        this.parsedIndex = i + 2
                        return
                    }
                    var colonIndex = this.allBuf.indexOf(b":", start: this.parsedIndex) ?? -1
                    if (colonIndex == -1 || colonIndex > i) {
                        throw Exception("header data is invalid:")
                    }
                    var key = String.fromUtf8(this.allBuf.slice(this.parsedIndex, colonIndex - this.parsedIndex), isAscii: true)
                    var (valStart, valLength) = this.allBuf.trim(colonIndex + 1, i - colonIndex - 1, TRIM_BYTE)
                    var val = String.fromUtf8(this.allBuf.slice(valStart, valLength), isAscii: true)
                    this.respHead.set(key, val)
                    this.parsedIndex = i+2
                case None =>
                    return

            }
        }
    }

    /**
     * The Function is parseBody
     *
     * @param request of http.Request)
     *
     * @return Type of StringStream
     * @since 0.29.3
     */
    public func parseBody(request: http.Request) : StringStream {
        if (request.method.toString() == "HEAD") {
            return StringStream("")
        }
        if(!this.isChunked) {
            if ( this.parsedIndex == this.allBuf.size()) {
                return StringStream("")
            }
            return StringStream(String.fromUtf8(this.allBuf.slice(this.parsedIndex, this.allBuf.size() - this.parsedIndex)))
        } else {
            var itemBody = Array<Byte>(this.allBuf.size() - this.parsedIndex, item: 0)
            var itemIndex = 0
            var chunkStart = this.parsedIndex
            do {
                var crlfIndex = match (this.allBuf.indexOf(CRLF, start: chunkStart)) {
                    case Some(x) => x
                    case None => throw Exception("chunked data is invalid:")
                }
                var chunkLenStr = String.fromUtf8(this.allBuf.slice(chunkStart, crlfIndex - chunkStart), isAscii: true)
                var chunkLen = match(parseUInt64("0x"+chunkLenStr)) {
                    case Some (x) => Int64(x)
                    case None => throw Exception("header data is invalid:")
                }
                if (chunkLen == 0) {
                    break
                }
                let bufferSlice = this.allBuf.slice(crlfIndex+2, chunkLen)
                bufferSlice.copyTo(itemBody, 0, itemIndex, chunkLen)
                itemIndex += chunkLen
                chunkStart = crlfIndex + 2 + chunkLen + 2
            } while (true)
            return StringStream(String.fromUtf8(itemBody, start: 0, length: itemIndex))
        }
    }
}

/**
 * The Function is toArray
 *
 * @param a of Array<UInt8>)
 *
 * @return Type of Array<Char>
 * @since 0.29.3
 */
public func toArray(a: Array<UInt8>) : Array<Char> {
    var buf2 = Array<Char>(a.size(), item: '\0')
    for (i in 0..buf2.size()) {
        buf2[i] = chr(UInt32(a[i]))
    }
    return buf2
}

/**
 * The Function is toArray
 *
 * @param a of Array<Char>)
 *
 * @return Type of Array<UInt8>
 * @since 0.29.3
 */
public func toArray(a: Array<Char>) : Array<UInt8> {
    var buf2 = Array<UInt8>(a.size(), item: 0)
    for (i in 0..buf2.size()) {
        buf2[i] = UInt8(ord(a[i]))
    }
    return buf2
}

/**
 * The Function is toArray
 *
 * @param a of ArrayList<String>)
 *
 * @return Type of Array<String>
 * @since 0.29.3
 */
public func toArray(a: ArrayList<String>) : Array<String> {
    return Array<String> (a.size(), {i => a[i]})
}


/*
 * The Function is closeBody
 *
 * @param req of http.Request
 * @param panic of Bool, and the Default value is true
 *
 * @return Type of Unit
 * @since 0.29.3
 */
func closeBody(req: http.Request, panic!: Bool = true): Unit {
    if (req.body is ReadCloseStream){
        match (req.body as ReadCloseStream) {
            case Some(v) =>
                if (!v.isClosed()) {
                    v.close()
                }
            case _ =>
                if (panic) {
                    throw RuntimeException("type cast failed.")
                }
        }
    }
}



/*
 * The class is HttpException inherited from RuntimeException
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
class HttpException <: RuntimeException {
    /**
     * The Function is init constructor
     *
     * @param message of String
     * @since 0.29.3
     */
    public init(message: String) {
        super(message)
    }
    /*
     * The Function is getClassName
     *
     * @return Type of String
     * @since 0.29.3
     */
    protected open override func getClassName(): String {
        return "HttpException"
    }
}




