/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */
/**
 * @file The file declars the xxxx class.
 */

package h2

from net import http.*
from std import time.*
from std import math.*
from std import socket.*
from std import fs.*
from std import collection.*
from http2 import buffer.*
from http2 import frame.*
from http2 import hpack.*
//from http2 import http.*
from http2 import exceptions.*

let errNilRequestURL: String = "http2: Request.URI is nil"
let errRequestHeaderListSize: String = "http2: request header list larger than peer's advertised limit"
let errReqBodyTooLong: String = "http2: request body larger than specified content length"
    // abort request body write; don't send cancel
let errStopReqBodyWrite: String = "http2: aborting request body write"
let errClientConnClosed: String = "http2: client conn is closed"

/**
 * The class is H2ClientStream
 * @author liyanqing14
 * @since 0.29.3
 */
public class H2ClientStream {
    public let ID: UInt32

    protected var cc: H2ClientConn
    protected var state: StreamState = IDLE

    protected let resp: H2Response
    // public let readQue: ConcurrentQueue<H2Request> = ConcurrentQueue<H2Request>()

    protected let isEndStream: SyncQueue<String> = SyncQueue<String>()

    protected var req: ?H2Request = None

    protected var requestedGzip: Bool = false
    protected var isHead: Bool = false
    protected var sentEndStream: Bool = false
    protected var sentHeaders: Bool = false
    protected var reqBody: InputStream
    protected var reqBodyContentLength: Int64 = 0 /* -1 means unknown */
    protected var reqBodyClosed: Bool = false /* body has been closed */

    public var allHttp2Frame: ArrayList<Http2Frame> = ArrayList<Http2Frame>()
    protected var hbuf: ByteBuffer = ByteBuffer(2048) /* HPACK encoder writes into this */
    protected var werr: String = ""
    protected var fe: FramesEncoder = FramesEncoder()

    protected var pushedFile: ?fs.File = None

    /**
     * The Function is init constructor
     *
     * @param ids of UInt32
     * @param cc of H2ClientConn
     * @param reqBody of ByteArrayStream
     * @since 0.29.3
     */
    public init (ids: UInt32, cc: H2ClientConn, reqBody: InputStream) {
        this.ID = UInt32(ids)
        this.cc = cc
        this.state = IDLE
        this.reqBody = reqBody
        this.resp = H2Response(cc.decode)
        this.reqBodyContentLength = reqBody.length
        cc.streamMap.put(ids, this)
    }

    public func rawCreatResponse() {
        this.resp.rawCreatResponse(this.req.getOrThrow())
    }
    
    /**
     * The Function is newStream
     *
     * @param ids of UInt32
     * @param cc of H2ClientConn
     * @param reqBody of ByteArrayStream
     *
     * @return Type of H2ClientStream
     * @since 0.29.3
     */
    public static func newStream(ids: UInt32, cc: H2ClientConn, reqBody: InputStream): H2ClientStream {
        return H2ClientStream(ids, cc, reqBody)
    }

    func doRequestHttp2(req: H2Request): Unit {
        this.req = req
        // this.reqBodyContentLength = actualContentLength(req)
        let err: String = this.writeRequest(req)
    }

    protected func getFrames(): ArrayList<Http2Frame> {
        let clone = allHttp2Frame
        allHttp2Frame = ArrayList<Http2Frame>()
        return clone
    }

    /* Array<UInt8>, error => (Array<UInt8>, String) */
    func encodeHeaders(req: H2Request, addGzipHeader: Bool, trailers: String, contentLength: Int64, encode: Encoder): (Array<UInt8>, String) {
        hbuf.reset()
        if (req.url.toString().isEmpty()) {
            return (EMPTY_ARRAY, errNilRequestURL)
        }
        var host: String = req.host
        if (host.isEmpty()) {
            host = req.url.host
        }
        var (hostp, err): (String, String) = punycodeHostPort(host)
        host = hostp
        if (!err.isEmpty()) {
            return (EMPTY_ARRAY, err)
        }

        var path: String = ""
        path = req.url.requestURI()
        if (!validPseudoPath(path)) {
            let orig: String = path
            path = path.trimLeft(req.url.scheme+"://"+host)
            if (!validPseudoPath(path)) {
                if (!req.url.opaque.isEmpty()) {
                    return (EMPTY_ARRAY, "invalid request :path ${orig} from URL.Opaque = ${req.url.opaque}")
                } else {
                    return (EMPTY_ARRAY, "invalid request :path ${orig}")
                }
            }
        }
        for ((k, vv) in req.header) {
            if (!validHeaderFieldName(k)) {
                return (EMPTY_ARRAY, "invalid HTTP header name ${k}")
            }
            for (str in vv) {
                if (!validHeaderFieldValue(str)) {
                    return (EMPTY_ARRAY, "invalid HTTP header value for header ${k}")
                }
            }
        }
        let arrHeaderField: ArrayList<HeaderField> = ArrayList<HeaderField>()
        var hlSize: Int64 = enumerateHeaders(host, path, req, addGzipHeader, trailers, contentLength, true, arrHeaderField)
        if (UInt64(hlSize) > cc.peerMaxHeaderListSize) {
            return (EMPTY_ARRAY, errRequestHeaderListSize)
        }
        enumerateHeaders(host, path, req, addGzipHeader, trailers, contentLength, false, arrHeaderField)
        let arrhbuf: Array<UInt8> = this.cc.encode.encode(arrHeaderField)
        return (arrhbuf, "")
    }

    private func enumerateHeaders(host: String, path: String, req: H2Request, addGzipHeader: Bool,
                                    trailers: String, contentLength: Int64, isFirst: Bool,
                                    arr: ArrayList<HeaderField>): Int64 {
        var hlSize: Int64 = 0
        hlSize += enumerateHeader(":authority", host, isFirst, arr)
        var m: RequestMethod = req.method
        if (m.toString().isEmpty()) {
            m = RequestMethod.GET
        }
        hlSize += enumerateHeader(":method", m.toString(), isFirst, arr)
        hlSize += enumerateHeader(":path", path, isFirst, arr)
        hlSize += enumerateHeader(":scheme", req.url.scheme, isFirst, arr)
        if (!trailers.isEmpty()) {
            hlSize += enumerateHeader("trailer", trailers, isFirst, arr)
        }

        let (hlnum, didUA, cleanUA): (Int64, Bool, Bool) = enumerateHeadersUtil(req, isFirst, arr)

        hlSize += hlnum

        if (shouldSendReqContentLength(req.method.toString(), contentLength)) {
            hlSize += enumerateHeader("content-length", formatInt(contentLength, 10), isFirst, arr)
        }
        if (addGzipHeader) {
            hlSize += enumerateHeader("accept-encoding", "gzip", isFirst, arr)
        }
        if (cleanUA) { req.header.remove("User-Agent") }
        if (!didUA) {
            hlSize += enumerateHeader("user-agent", defaultUserAgent, isFirst, arr)
        }
        return hlSize
    }

    private func enumerateHeadersUtil(req: H2Request, isFirst: Bool, arr: ArrayList<HeaderField>): (Int64, Bool, Bool) {
        var hlSize: Int64 = 0
        var didUA: Bool = false
        var cleanUA: Bool = false
        for ((k, value) in req.header) {
            var vv: ArrayList<String> = value
            if (asciiEqualFold(k, "host") || asciiEqualFold(k, "content-length")) {
                continue
            } else if (asciiEqualFold(k, "connection") ||
                asciiEqualFold(k, "proxy-connection") ||
                asciiEqualFold(k, "transfer-encoding") ||
                asciiEqualFold(k, "upgrade") ||
                asciiEqualFold(k, "keep-alive")) {
                continue
            } else if (asciiEqualFold(k, "user-agent")) {
                for (str in vv) {
                    if (str.equals("cangjie-http-client/1.1")) {
                        cleanUA = true
                    }
                }
                if (!cleanUA) {
                    didUA = true
                    if (vv.size < 1) {
                        continue
                    }
                    vv = vv.slice(0 .. 1)
                    if (vv[0].isEmpty()) {
                        continue
                    }
                }
            } else if (asciiEqualFold(k, "cookie")) {
                hlSize += handleHeaderCookie(vv, isFirst, arr)
                continue
            }
            for (v in vv) {
                hlSize += enumerateHeader(k, v, isFirst, arr)
            }
        }
        return (hlSize, didUA, cleanUA)
    }

    func handleHeaderCookie(vv: ArrayList<String>, isFirst: Bool, arr: ArrayList<HeaderField>): Int64 {
        var hlSize: Int64 = 0
        for (v in vv) {
            var str: String = v
            while(true) {
                var p: Int64 = getInt64Index(str.indexOf(';'))
                if (p < 0) {
                    break
                }
                hlSize += enumerateHeader("cookie", str.substring(0, p), isFirst, arr)
                p++
                while (p + 1 <= str.size && str[p] == ' ') {
                    p++
                }
                str = str.substring(p)
            }
            if (str.size > 0) {
                hlSize += enumerateHeader("cookie", str, isFirst, arr)
            }
        }
        return hlSize
    }

    /* processing compressed headers */
    func enumerateHeader(name: String, value: String, isFirst: Bool, arr: ArrayList<HeaderField>): Int64 {
        var num: Int64 = 0
        if (isFirst) {
            let hf: HeaderField = HeaderField(name, value)
            num = hf.size()
        } else {
            let (names, ascii): (String, Bool) = asciiToLower(name)
            if (!ascii) {
                return num
            }
            let hf: HeaderField = HeaderField(names, value)
            arr.append(hf)
        }
        return num
    }

    /* error => String */
    func writeHeaders(streamID: UInt32, endStream: Bool, maxFrameSize: Int64, hdrsArr: Array<UInt8>): Unit {
        // first frame written (HEADERS is first, then CONTINUATION)
        var first: Bool = true
        var hdrs: Array<UInt8> = hdrsArr
        while (hdrs.size > 0) {
            var chunk: Array<UInt8> = hdrs
            if (chunk.size > maxFrameSize) {
                chunk = chunk[0..maxFrameSize]
            }
            if (chunk.size == hdrs.size) {
                hdrs = Array<UInt8>()
            } else {
                hdrs = hdrs[chunk.size..hdrs.size]
            }
            let endHeaders: Bool = hdrs.size == 0
            if (first) {
                let headersFrame: Http2Frame = writeHeadersFrame(streamID, chunk, endStream, endHeaders, 0)
                this.allHttp2Frame.append(headersFrame)
                first = false
            } else {
                let continuationFrame: Http2Frame = writeContinuation(streamID, endHeaders, chunk)
                allHttp2Frame.append(continuationFrame)
            }
        }
    }

    // WriteData writes a DATA frame
    func writeData(streamID: UInt32, endStream: Bool, chunk: Array<UInt8>, padLength: Int64): String {
        let dataFrame: Http2Frame = writeDataPadded(streamID, endStream, chunk, padLength)
        allHttp2Frame.append(dataFrame)
        return ""
    }

    /* ([]byte, error) => (Array<UInt8>, String) */
    func encodeTrailers(trailer: Header, encode: Encoder): (Array<UInt8>, String) {
        hbuf.reset()

        var hlSize: UInt64 = 0
        for ((k, vv) in trailer) {
            for (v in vv) {
                let hf: HeaderField = HeaderField(k, v)
                hlSize += UInt64(hf.size())
            }
        }
        if (hlSize > cc.peerMaxHeaderListSize) {
            return (EMPTY_ARRAY, errRequestHeaderListSize)
        }

        for ((k, vv) in trailer) {
            let (lowKey, ascii): (String, Bool) = asciiToLower(k)
            if (!ascii) {
                continue
            }
            for (v in vv) {
                writeHeader(lowKey, v, encode)
            }
        }
        return (Array<UInt8>(hbuf.getBuf()), "")
    }

    func writeHeader(name: String, value: String, encode: Encoder) {
        let hf: HeaderField = HeaderField(name, value)
        this.cc.encode.encode([hf])
    }


    private func writeRequest(req: H2Request): String {
        var err: String = ""
        if (!cc.hts.getDisableCompression() &&
            getStringIndex(req.header.get("Accept-Encoding")).isEmpty() &&
            getStringIndex(req.header.get("Range")).isEmpty()) {
                requestedGzip = true
        }

        err = encodeAndWriteHeaders(req)
        if (!err.isEmpty()) {
            return err
        }

        let hasBody: Bool = reqBodyContentLength != 0
        if (!hasBody) {
            sentEndStream = true
        } else {
            err = writeRequestBody(req)
            if (!err.isEmpty()) {
                if (!err.equals(errStopReqBodyWrite)) {
                    return err
                }
            } else {
                sentEndStream = true
            }
        }
        return err
    }

    /* (err error) => String */
    func writeRequestBody(req: H2Request): String {
        var body: InputStream = this.reqBody
        var sentEnd: Bool = false // whether we sent the final DATA frame END_STREAM

        let trailerNum: Int64 = getHeaderSize(req.trailer)

        var remainLen: Int64 = reqBodyContentLength
        let hasContentLen: Bool = remainLen != -1

        let maxFrameSize: Int64 = Int64(cc.maxFrameSize)
        let scratchLen: Int64 = frameScratchBufferLen(cc.maxFrameSize)
        var buf: Array<Byte> = Array<Byte>(scratchLen, item: 0)

        var sawEOF: Bool = false
        while (!sawEOF) {
            let n: Int64 = body.read(buf)
            var err: String = ""
            if (hasContentLen) {
                remainLen -= n
                if (remainLen == 0) {
                    err = "EOF"
                }
                if (remainLen < 0) {
                    err = errReqBodyTooLong
                    return err
                }
            }
            if (!err.isEmpty()) {
                let bodyClosed: Bool = reqBodyClosed
                if (bodyClosed) {
                    return errStopReqBodyWrite
                } else if (err.equals("EOF")) {
                    sawEOF = true
                    err = ""
                } else {
                    return err
                }
            }
            let (errFlag, sentEndFlag): (String, Bool) = writeRequestBodyUtil(n, buf, err, sentEnd, sawEOF, trailerNum)
            err = errFlag
            sentEnd = sentEndFlag
            if (!err.isEmpty()) {
                return err
            }
        }
        if (sentEnd) {
            return ""
        }
        return writeRequestBodyEnd(req, maxFrameSize, trailerNum)
    }

    func writeRequestBodyUtil(n: Int64, buf: Array<UInt8>, errFlag: String, sentEndFlag: Bool, sawEOF: Bool, trailerNum: Int64): (String, Bool) {
        var err: String = errFlag
        var sentEnd: Bool = sentEndFlag
        let hasTrailers: Bool = trailerNum != 0
        var remain: Array<UInt8> = buf[0..n]
        while (remain.size > 0 && err.isEmpty()) {
            var (allowed, erral): (Int64, String) = awaitFlowControl(remain.size)
            err = erral
            if (!err.isEmpty()) {
                return (err, sentEnd)
            }
            var data: Array<UInt8> = remain
            if (allowed < remain.size) {
                data = remain[0..allowed]
                remain = remain[allowed..remain.size]
            } else {
                remain = Array<UInt8>()
            }
            sentEnd = sawEOF && remain.size == 0 && !hasTrailers
            err = this.writeData(ID, sentEnd, data, 0)
        }
        if (!err.isEmpty()) {
            return (err, sentEnd)
        }
        return (err, sentEnd)
    }

    func writeRequestBodyEnd(req: H2Request, maxFrameSize: Int64, trailerNum: Int64): String {
        let trailer: Header = req.trailer
        var trls: Array<UInt8> = Array<UInt8>()
        var err: String = ""
        if (trailerNum > 0) {
            let (trlsArr, errtrls): (Array<UInt8>, String) = this.encodeTrailers(trailer, this.cc.encode)
            trls = trlsArr
            err = errtrls
            if (!err.isEmpty()) {
                return err
            }
        }
        // Two ways to send END_STREAM: either with trailers, or with an empty DATA frame.
        if (trls.size > 0) {
            this.writeHeaders(ID, true, maxFrameSize, trls)
        } else {
            err = this.writeData(ID, true, Array<UInt8>(), 0)
        }
        return err
    }

    /* (taken int32, err error) */
    func awaitFlowControl(maxBytes: Int64): (Int64, String) {
        var take: Int64 = maxBytes
        if (cc.closed.load()) {
            return (0, errClientConnClosed)
        }
        if (reqBodyClosed) {
            return (0, errStopReqBodyWrite)
        }
        if (maxBytes > Int64(cc.maxFrameSize)) {
            take = Int64(cc.maxFrameSize)
        }
        return (take, "")
    }

    func frameScratchBufferLen(maxFrameSize: UInt32): Int64 {
        let max: Int64 = 512 << 10
        var n: Int64 = Int64(maxFrameSize)
        if (n > max) {
            n = max
        }
        let cl: Int64 = reqBodyContentLength
        if (cl != -1 && (cl + 1) < n) {
            n = cl + 1
        }
        if (n < 1) {
            return 1
        }
        return n // doesn't truncate; max is 512K
    }

    /* String => error */
    func encodeAndWriteHeaders(req: H2Request): String {
        let (trailers, err): (String, String) = commaSeparatedTrailers(req)
        if (!err.isEmpty()) {
            return err
        }
        let hasTrailers: Bool = !trailers.isEmpty()
        let contentLen: Int64 = this.reqBodyContentLength
        let hasBody: Bool = (contentLen != 0)
        let (hdrs, errEH): (Array<UInt8>, String) = this.encodeHeaders(req, requestedGzip, trailers, contentLen, this.cc.encode)

        if (!errEH.isEmpty()) {
            return errEH
        }

        // Write the request.
        let endStream: Bool = (!hasBody && !hasTrailers)
        this.sentHeaders = true
        this.writeHeaders(ID, endStream, Int64(cc.maxFrameSize), hdrs)
        return err
    }

    /* (String, String) => (String, error) */
    func commaSeparatedTrailers(req: H2Request): (String, String) {
        var arrHeaderKey: ArrayList<String> = ArrayList<String>(1024)
        let trailer: Header = req.trailer
        for ((name,v) in trailer) {
            var k: String = name
            k = canonicalHeaderKey(k)
            if (k.equals("Transfer-Encoding") || k.equals("Trailer") || k.equals("Content-Length")) {
                return ("", "invalid Trailer key ${k}")
            }
            arrHeaderKey.append(k)
        }
        if (arrHeaderKey.size > 0) {
            arrHeaderKey.sortBy({ rht: String, lht: String =>
                if (rht < lht) {
                    return Ordering.LT
                }
                if (rht > lht) {
                    return Ordering.GT
                }
                return Ordering.EQ
            }, stable: true)
            return (String.join(Array(arrHeaderKey), delimiter: ","), "")
        }
        return ("", "")
    }

    /**
     * The Function is sendFrame
     *
     * @param fm of Http2Frame
     * @since 0.29.3
     */
    public func sendFrame(fm: Http2Frame) {
        this.cc.ws.put(fm)
    }

    /**
     * The Function is readFrame
     *
     * @return Type of ?Http2Frame
     * @since 0.29.3
     */
    public func readFrame(): ?Http2Frame {
        return None
    }
}
