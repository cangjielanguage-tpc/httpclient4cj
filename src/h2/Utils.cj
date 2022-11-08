/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the utils.
 */

package h2

from encoding import base64.*
from std import convert.*

let RUNESELF: UInt32  = 0x80
let NSMALLS: Int64 = 100
let digits: String = "0123456789abcdefghijklmnopqrstuvwxyz"

let EMPTY_ARRAY: Array<UInt8> = Array<UInt8>()

let SMALLS_STRING: String = "00010203040506070809101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899"

func validStreamID(streamID: UInt32): Bool {
    return streamID != 0 && (streamID & (1<<31)) == 0
}

func writeHeadersFrame(streamID: UInt32, chunk: Array<UInt8>, endStream: Bool, endHeaders: Bool, padLength: Int64): Http2Frame {
    if (!validStreamID(streamID)) {
        throw Http2Exception("Illegal streamid.")
    }
    var bBuffer: ByteBuffer = ByteBuffer(chunk)
    let data: Array<ByteBuffer> = [bBuffer]
    var flags: UInt8 = 0
    if (padLength != 0) {
        flags |= FLAG_PADDED
    }
    if (endStream) {
        flags |= FLAG_END_STREAM
    }
    if (endHeaders) {
        flags |= FLAG_END_HEADERS
    }
    return Http2Frame(mytypes: FREAM_HEADERS, myflags: flags, mystreamID: streamID, data: data, padLength: padLength)
}

func writeDataPadded(streamID: UInt32, endStream: Bool, chunk: Array<UInt8>, padLength: Int64): Http2Frame {
    var bBuffer: ByteBuffer = ByteBuffer(chunk)
    let data: Array<ByteBuffer> = Array<ByteBuffer>([bBuffer])
    var flags: UInt8 = 0

    if (endStream) {
        flags |= FLAG_END_STREAM
    }
    if (padLength != 0) {
        flags |= FLAG_PADDED
    }
    return Http2Frame(mytypes: FREAM_DATA, myflags: flags, mystreamID: streamID, data: data, padLength: padLength)
}

func writeContinuation(streamID: UInt32, endHeaders: Bool, headerBlockFragment: Array<UInt8>): Http2Frame {
    if (!validStreamID(streamID)) {
        throw Http2Exception("Illegal streamid.")
    }
    var flags: UInt8 = 0
    if (endHeaders) {
        flags |= FLAG_END_HEADERS
    }
    var bBuffer: ByteBuffer = ByteBuffer(headerBlockFragment)
    let data: Array<ByteBuffer> = Array<ByteBuffer>([bBuffer])
    return Http2Frame(mytypes: FREAM_CONTINUATION, myflags: flags, mystreamID: streamID, data: data)
}

// Itoa is equivalent to FormatInt(int64(i), 10).
public func itoa(num: Int64): String {
    return formatInt(num, 10)
}

// FormatInt returns the string representation of i in the given base,
// for 2 <= base <= 36. The result uses the lower-case letters 'a' to 'z'
// for digit values >= 10.
public func formatInt(num: Int64, base: Int64): String {
    if (0 <= num && num < NSMALLS && base == 10) {
        return small(num)
    }
    return formatBits(UInt64(num), base, num < 0, false)
}

// small returns the string for an i with 0 <= i < nSmalls.
func small(num: Int64): String {
    if (num < 10) {
        return digits.substring(num, 1)
    }
    return SMALLS_STRING.substring(num * 2, 2)
}

func formatBits(num: UInt64, base: Int64, neg: Bool, append_: Bool): String {
    if (base < 2 || base > digits.size) {
        throw Exception("strconv: illegal AppendInt/FormatInt base")
    }
    // 2 <= base && base <= digits.size()

    var a: Array<UInt8> =  Array<UInt8>(64 + 1, item: 0)// +1 for sign of 64bit value in base 2
    var i: Int64 = a.size

    var u: UInt64 = num
    if (neg) {
        u = -u
    }

    if (base == 10) {
        var us: UInt64 = u
        while (us >= 100) {
            let isu: Int64 = Int64(us % 100 * 2)
            us /= 100
            i -= 2
            a[i + 1] = UInt8(UInt32(SMALLS_STRING[isu + 1]))
            a[i] = UInt8(UInt32(SMALLS_STRING[isu]))
        }

        // us < 100
        let ius: Int64 = Int64(us * 2)
        i--
        a[i] = UInt8(UInt32(SMALLS_STRING[ius + 1]))
        if (us >= 10) {
            i--
            a[i] = UInt8(UInt32(SMALLS_STRING[ius]))
        }

    }

    // add sign, if any
    if (neg) {
        i--
        a[i] = UInt8(UInt32('-'))
    }
    if (append_) {
        return ""
    }
    return String.fromUtf8(a[i .. a.size])
}

func isPowerOfTwo(x: Int64): Bool {
    let num: Int64 = x&(x-1)
    return num == 0
}

func shouldSendReqContentLength(method: String, contentLength: Int64): Bool {
    if (contentLength > 0) {
        return true
    }
    if (contentLength < 0) {
        return false
    }
    if (method.equals("POST") || method.equals("PUT") || method.equals("PATCH")) {
        return true
    }
    return false
}

// Traverse the header for the first time and calculate the number of bytes to ensure that it does not exceed peermaxheaderlistsize.
// Before encoding the header, this is a separate process to prevent modifying the hpack state.
func enumerateHeadersPlan(name: String, value: String): Int64 {
    let hf: HeaderField = HeaderField(name, value)
    return hf.size()
}

func validPseudoPath(str: String): Bool {
    return (str.size > 0 && str[0] == '/') || str.equals("*")
}

//(string, error) => (String, String)
public func punycodeHostPort(str: String): (String, String) {
    if (isASCII(str)) {
        return (str, "")
    }

    var (host, port, err): (String, String, String) = splitHostPort(str)
    if (!err.isEmpty()) {
        host = str
        port = ""
    }
    if (port.isEmpty()) {
        return (host, "")
    }
    return (joinHostPort(host, port), "")
}

func isASCII(str: String): Bool {
    for (c in str) {
        if (UInt32(c) >= RUNESELF) {
            return false
        }
    }
    return true
}

/* For example, the canonical key for "accept-encoding" is "Accept-Encoding". */
public func canonicalHeaderKey(str: String): String {
    return canonicalMIMEHeaderKey(str)
}

/*
 * [
 *         '!', '#', '$', '%', '&', '\'', '*', '+', '-', '.',
 *         '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
 *         'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
 *         '^', '_', '`',
 *         'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
 *         '|', '~'
 * ]
 */
var isTokenTable: Array<Bool> = [
    false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false,
    true, false, true, true, true, true, true, false,
    false, true, true, false, true, true, false,
    true, true, true, true, true, true, true, true, true, true,
    false, false, false, false, false, false, false,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    false, false, false, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    false, true, false, true, false
]
let IS_TOKEN_TABLE_SIZE: Int64 = 127

public func validHeaderFieldName(str: String): Bool {
    if (str.size == 0) {
        return false
    }
    for (c in str) {
        if (!validHeaderFieldByte(c)) {
            return false
        }
    }
    return true
}

let badTrailer: Array<String> = [
    "Authorization",
    "Cache-Control",
    "Connection",
    "Content-Encoding",
    "Content-Length",
    "Content-Range",
    "Content-Type",
    "Expect",
    "Host",
    "Keep-Alive",
    "Max-Forwards",
    "Pragma",
    "Proxy-Authenticate",
    "Proxy-Authorization",
    "Proxy-Connection",
    "Range",
    "Realm",
    "Te",
    "Trailer",
    "Transfer-Encoding",
    "Www-Authenticate"
]

/* Whether the report name is a valid title field name to be displayed in the trailer. */
public func validTrailerHeader(key: String): Bool {
    let name: String = canonicalMIMEHeaderKey(key)
    return !(name.startsWith("If-") || badTrailer.contains(name))
}

func validHeaderFieldByte(c: Char): Bool {
    let index:Int64 = Int64(UInt32(c))
    return index > 0 && index < IS_TOKEN_TABLE_SIZE && isTokenTable[index]
}

public func canonicalMIMEHeaderKey(str: String): String {
    var charArray: Array<Char> = str.toCharArray()
    var upper: Bool = true
    var index: Int64 = -1
    for (c in charArray) {
        index++
        if (!validHeaderFieldByte(c)) {
            return str
        }
        // Capitalize the first letter after the first letter and -, and lower case the rest. No other processing is required
        if (upper && 'a' <= c && c <= 'z') {
            charArray[index] = upperChar(c)
        }
        if (!upper && 'A' <= c && c <= 'Z') {
            charArray[index] = lowerChar(c)
        }
        upper = (c == '-')
    }
    return String(charArray)
}

public func validHeaderFieldValue(str: String): Bool {
    for (c in str) {
        if (isCTL(c) && !isLWS(c)) {
            return false
        }
    }
    return true
}

let CTL: UInt32 = 0x7f
func isCTL(c: Char): Bool {
    return c < ' ' || UInt32(c) == CTL
}

func isLWS(c: Char): Bool {
    return c == ' ' || c == '\t'
}


//schema://host[:port#]/path/.../[?query-string][#anchor]
//return type：(host, port, err): (String, String, String)
public func splitHostPort(hostport: String): (String, String, String) {

    let missingPort: String   = "missing port in address"
    let tooManyColons: String = "too many colons in address"

    var j: Int64 = 0
    var k: Int64 = 0
    var host: String = ""
    var port: String = ""

    //schema://host[:port#]/path/.../[?query-string][#anchor]
    let lastColonIndex: Int64 = getInt64Index(hostport.lastIndexOf(':'))
    if (lastColonIndex < 0) {
        return (hostport, "", missingPort)
    }

    if (hostport[0] == '[') {
        // The first "]" should precede the last ":"
        let end: Int64 = getInt64Index(hostport.indexOf(']'))
        if (end < 0) {
            return (hostport, "", "missing ']' in address")
        }

        let colonNum: Int64 = end + 1
        if (colonNum != lastColonIndex && colonNum == hostport.size) {
            return (hostport, "", missingPort)
        } else if (colonNum != lastColonIndex && hostport[end + 1] == ':') {
            // "]" is not followed by the last colon.
            return (hostport, "", tooManyColons)
        } else if (colonNum != lastColonIndex) {
            // ']' is not followed by a colon
            return (hostport, "", missingPort)
        }

        host = hostport[1..end]
        j = 1
        k = end + 1
    } else {
        host = hostport[0..lastColonIndex]
        getInt64Index(hostport.indexOf(':'))
        if (getInt64Index(hostport.indexOf(':')) >= 0) {
            return (hostport, "", tooManyColons)
        }
    }
    let num: Int64 = hostport.size
    if (getInt64Index(hostport[j..num].indexOf('[')) >= 0) {
        return (hostport, "", "unexpected '[' in address")
    }
    if (getInt64Index(hostport[k..num].indexOf(']')) >= 0) {
        return (hostport, "", "unexpected ']' in address")
    }

    let numi: Int64 = lastColonIndex + 1
    port = hostport[numi..num]
    return (host, port, "")
}

func getInt64Index(index: Option<Int64>): Int64 {
    match (index) {
        case Some(v) => return v
        case None => return -1
    }
}

public func joinHostPort(host: String, port: String): String {
    /* handle according to IPv6 if host has colons.*/
    if (host.contains(':')) {
        return "[" + host + "]:" + port
    }
    return host + ":" + port
}

/* checkConnHeaders checks whether req has any invalid connection-level headers.
 * per RFC 7540 section 8_1_2_2: Connection-Specific Header Fields.
 * Certain headers are special-cased as okay but not transmitted later.
 */
func checkConnHeaders(req: H2Request): String {
    let upgradeStr: String = req.header.get("Upgrade") ?? ""
    if (!upgradeStr.isEmpty()) {
        return "http2: invalid Upgrade request header: {upgradeStr}"
    }

    let arrEncoding: ArrayList<String> = req.header.getAll("Transfer-Encoding")
    let num: Int64 = arrEncoding.size
    if (num > 0 && (num > 1 || !arrEncoding[0].isEmpty() && !arrEncoding[0].equals("chunked"))) {
        return "http2: invalid Transfer-Encoding request header: ${arrEncoding}"
    }

    let arrConn: ArrayList<String> = req.header.getAll("Connection")
    let numConn: Int64 = arrConn.size
    if (numConn > 0) {
        let arrConn0: String = arrConn[0]
        if (numConn > 1 || !arrConn0.isEmpty() && !asciiEqualFold(arrConn0, "close") && !asciiEqualFold(arrConn0, "keep-alive")) {
            return "http2: invalid Connection request header: ${arrConn}"
        }
    }
    return ""
}

func asciiEqualFold(str: String, src: String): Bool {
    if (str.size != src.size) {
        return false
    }
    return str.toAsciiLower().equals(src.toAsciiLower())
}

/* If s is ASCII and printable, the lowercase version of S is returned, regardless of whether it is ASCII and printable.
 * (lower string, ok bool) => (String, Bool)
 */
func asciiToLower(str: String): (String, Bool) {
    if (!isASCIIPrint(str)) {
        return ("", false)
    }
    return (str.toAsciiLower(), true)
}

func isASCIIPrint(str: String): Bool {
    for (c in str) {
        if (c < ' ' || c > '~') {
            return false
        }
    }
    return true
}

let DIFFERENCE_VALUE_A: UInt32 = 32

/* lower returns the ASCII lowercase version of b. */
func lowerChar(b: Char): Char {
    if ('A' <= b && b <= 'Z') {
        return Char(UInt32(b) + DIFFERENCE_VALUE_A)
    }
    return b
}

func upperChar(b: Char): Char {
    if ('a' <= b && b <= 'z') {
        return Char(UInt32(b) - DIFFERENCE_VALUE_A)
    }
    return b
}

func getStringIndex(index: Option<String>): String {
    match (index) {
        case Some(v) => return v
        case None => return ""
    }
}

func getHeaderSize(header: Header): Int64 {
    let arr: Iterable<(String, ArrayList<String>)> = header.iterator()
    var num: Int64 = 0
    for((k,v) in arr) {
        num++
    }
    return num
}

/*
 * Base64url encoding process:
 *     1. Plaintext is encrypted using Base64
 *     2. The following coding is performed on the basis of Base64:
 *         - Remove trailing '='
 *         - Replace "+" with "-"
 *         - Replace "/" with "/"
 */
public func base64UrlEncode(bytes: Array<UInt8>): String {
    return toBase64String(bytes).split('=')[0].replace('+', '-').replace('/', '_')
}

/*
 * Base64url decoding process:
 *     1. Decode the base64url encoding as follows:
 *         - Replace "-" with "+"
 *         - Put "\u" Replace with "/"
 *         - (Calculate base64url encoding length)%4
 *             - The result is 0, do not process
 *             - The result is 2, and "= =" is added to the string
 *             - The result is 3, and "=" is added to the string
 *     2. Decode ciphertext with Base64 to obtain original plaintext
 */
public func base64UrlDecode(b64Url: String): Array<UInt8> {
    var b64 = b64Url.replace('-', '+').replace('_', '/')
    match (b64.size % 4) {
        case 0 => ()
        case 2 => b64 += "=="
        case 3 => b64 += "="
        case _ => throw NoneValueException("fail")
    }
    return fromBase64String(b64).getOrThrow()
}

func getUInt8FromFrames(frame: Http2Frame): Array<UInt8> {
    let fe: FramesEncoder = FramesEncoder()
    let arrEncoder: Array<ByteBuffer> = fe.encodeFrame(frame)
    var res: ArrayList<UInt8> = ArrayList<UInt8>()
    for (bb in arrEncoder) {
        res.appendAll(bb.getBuf())
    }
    return Array<UInt8>(res)
}

/* Reports whether the given response status code allows the body */
func bodyAllowedForStatus(status: Int64): Bool {
    return !((status >= 100 && status <= 199) || status == 204 || status == 304)
}

/* Encode the HTTP header. If the key is not zero, then (k, h[k]) is encoded only when k is in the key. */



func validWireHeaderFieldName(v: String): Bool {
    if (v.isEmpty()) {
        return false
    }
    for (r in v) {
        if (!isTokenRune(Int64(UInt32(r)))) {
            return false
        }
        if ('A' <= r && r <= 'Z') {
            return false
        }
    }
    return true
}

public func isTokenRune(r: Int64): Bool {
    return r < isTokenTable.size && isTokenTable[r]
}

var commonBuildOnce: Bool = false
let commonLowerHeader: HashMap<String, String> = HashMap<String, String>() // Go-Canonical-Case -> lower-case
let commonCanonHeader: HashMap<String, String> = HashMap<String, String>() // lower-case -> Go-Canonical-Case

func buildCommonHeaderMapsOnce(): Unit {
    if (commonBuildOnce) {return}
    buildCommonHeaderMaps()
    commonBuildOnce = true
}

let common: Array<String> = [
    "accept",
    "accept-charset",
    "accept-encoding",
    "accept-language",
    "accept-ranges",
    "age",
    "access-control-allow-origin",
    "allow",
    "authorization",
    "cache-control",
    "content-disposition",
    "content-encoding",
    "content-language",
    "content-length",
    "content-location",
    "content-range",
    "content-type",
    "cookie",
    "date",
    "etag",
    "expect",
    "expires",
    "from",
    "host",
    "if-match",
    "if-modified-since",
    "if-none-match",
    "if-unmodified-since",
    "last-modified",
    "link",
    "location",
    "max-forwards",
    "proxy-authenticate",
    "proxy-authorization",
    "range",
    "referer",
    "refresh",
    "retry-after",
    "server",
    "set-cookie",
    "strict-transport-security",
    "trailer",
    "transfer-encoding",
    "user-agent",
    "vary",
    "via",
    "www-authenticate"
]

func buildCommonHeaderMaps() {
    for (v in common) {
        let chk: String = canonicalHeaderKey(v)
        commonLowerHeader.put(chk, v)
        commonCanonHeader.put(v, chk)
    }
}

func lowerHeader(v: String): (String, Bool) {
    buildCommonHeaderMapsOnce()
    let value: String = commonLowerHeader.get(v) ?? ""
    if (!value.isEmpty()) {
        return (value, true)
    }
    return asciiToLower(v)
}

func httpCodeString(code: Int64): String {
    if (code == 200) {
        return "200"
    } else if (code == 404) {
        return "404"
    } else {
        return "404"
    }
    return formatInt(code, 10)
}

/* Report whether req should use its own connection for a single request, and then close the connection. */
func isConnectionCloseRequest(req: H2Request): Bool {
    let values: ArrayList<String> = match (req.header.get("Connection")) {
        case Some(v) => req.header.getAll("Connection")
        case None => ArrayList<String>()
    }
    return !req.isClosed() || headerValuesContainsToken(values, "close")
}

/* Whether any string in the report value contains the provided token is not ASCII case sensitive.
 * Whether to include tokens in their comma separated tokens, ASCII case insensitive.
 */
public func headerValuesContainsToken(values: ArrayList<String>, token: String): Bool {
    for (str in values) {
        if (headerValueContainsTokenUtil(str, token)) {
            return true
        }
    }
    return false
}

func headerValueContainsTokenUtil(str: String, tokenstr: String): Bool {
    var src: String = str.toAsciiLower()
    let token: String = tokenstr.toAsciiLower()
    var index: Int64 = getInt64Index(src.indexOf(','))
    while (index != -1) {
        if (src.substring(0, index + 1).trimAscii().equals(token)) {
            return true
        }
        src = src.substring(index + 1)
        index = getInt64Index(src.indexOf(','))
    }
    return src.trimAscii().equals(token)
}

/* Whether the report T represents zero time instant, that is, 00:00:00 UTC on January 1 of the first year. */
func timeIsZero(t: Time): Bool {
    return t.second() == 0 && t.nanosecond() == 0
}

/*
 * Returns the given permission (host /ip or host: port /ip: port) and returns host: port. If necessary, add port 443.
 * (scheme: String, authority: String) => req.URL.Scheme, req.URL.Host
 */
func authorityAddr(scheme: String, authority: String): String {
    var (host, port, err): (String, String, String) = splitHostPort(authority)
    if (!err.isEmpty()) {
        port = "443"
        if (scheme.equals("http")) {
            port = "80"
        }
        host = authority
    }
    /* IPv6 address text, no port: */
    if (host.startsWith("[") && host.endsWith("]")) {
        return host + ":" + port
    }
    return joinHostPort(host, port)
}


