/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ExchangeCodec class.
 */
package okhttp


from http2 import http.*
from net import http.* as h2.*
from std import io.*


/**
 * The interface is ExchangeCodec
 * @author luoyukai4
 * @since 0.29.3
 */
public interface ExchangeCodec {

    func write(request: Request): Unit

    func readResponseHeaders(): ResponseBuilder

    func reportedContentLength(): Int64

    func openResponseBody(): Option<ResponseBody>

    func getConnection(): Connection

    func cancel(): Unit
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
 * The class is ExchangeCodec
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Http1ExchangeCodec<: ExchangeCodec{

    /* let member STATE_IDLE type is Int64 */
    private static let STATE_IDLE: Int64 = 0// Idle connections are ready to write request headers.
    /* let member STATE_OPEN_REQUEST_BODY type is Int64 */
    private static let STATE_OPEN_REQUEST_BODY: Int64 = 1
    /* let member STATE_WRITING_REQUEST_BODY type is Int64 */
    private static let STATE_WRITING_REQUEST_BODY: Int64 = 2
    /* let member STATE_READ_RESPONSE_HEADERS type is Int64 */
    private static let STATE_READ_RESPONSE_HEADERS: Int64 = 3
    /* let member STATE_OPEN_RESPONSE_BODY type is Int64 */
    private static let STATE_OPEN_RESPONSE_BODY: Int64 = 4
    /* let member STATE_READING_RESPONSE_BODY type is Int64 */
    private static let STATE_READING_RESPONSE_BODY: Int64 = 5
    /* let member STATE_CLOSED type is Int64 */
    private static let STATE_CLOSED: Int64 = 6
    /* let member HEADER_LIMIT type is Int64 */
    private static let HEADER_LIMIT: Int64 = 256 * 1024
    /* var member realConnection type is Connection */
    private var realConnection: Connection
    /* var member client type is OkHttpClient */
    private var client: OkHttpClient
    /* var member allBuf type is ByteArrayStream */
    private var allBuf: ByteArrayStream = ByteArrayStream()
    /* var member parsedIndex type is Int64 */
    private var parsedIndex: Int64 = 0
    /* var member state type is Int64 */
    private var state: Int64 = STATE_IDLE
    /* let member readLength type is Int64 */
    private let readLength: Int64 = HEADER_LIMIT
    /* var member respHead type is Header */
    private var respHead: Header = Header()
    /* var member res type is ResponseBuilder */
    private var res:ResponseBuilder = ResponseBuilder()
    private var readTimeout: Option<Duration>
    private var writeTimeout: Option<Duration>

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @param realConnection of Connection
     * @since 0.29.3
     */
    public init (client: OkHttpClient, realConnection: Connection, readTimeout:Option<Duration>, writeTimeout: Option<Duration>) {
        this.client = client
        this.realConnection = realConnection
        this.readTimeout = readTimeout
        this.writeTimeout = writeTimeout
    }

    /**
     * The Function is write
     *
     * @param request of Request
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func write(request: Request): Unit {
        let req4cj =  request.toHttpRequest()
        var writeBuf: ByteArrayStream = ByteArrayStream()

        req4cj.copyTo(writeBuf)
        let socket = this.realConnection.getSocket().getOrThrow()
        match (writeTimeout) {
            case Some(time) => socket.write(writeBuf.readToEnd(), time)
            case None => socket.write(writeBuf.readToEnd())

        }
        state = STATE_OPEN_REQUEST_BODY
    }

    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    public func readResponseHeaders(): ResponseBuilder {
        if (state != STATE_OPEN_REQUEST_BODY) {
            throw Exception("state: ${state}")
        }
        var readBuf: Array<Byte> = Array<Byte>(readLength, item: 0)
        var lenNum: Int64 = this.readBytesToBuffer(readBuf)
        if (lenNum <= 0) {
            throw Exception()
        }
        this.allBuf.write(readBuf.slice(0, lenNum))
        return this.parseHead()
    }

    /*
     * The Function is reportedContentLength
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    public func reportedContentLength(): Int64{
        if(!hasBody(res.build())) {
            return 0
        }
        match (this.respHead.get("Transfer-Encoding")) {
            case Some(s) =>
                if (s == "chunked") {
                    return -1
                }
            case None => ()
        }
        match (this.respHead.get("Content-Length")) {
            case Some(s) =>
            match (parseInt64(s)) {
                case Some(n) => return n
                case None => throw HttpException("Content-Length is invalid: ${s}.")
            }
            case None => return  -1
        }
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of ResponseBody
     * @since 0.29.3
     */
    public func openResponseBody(): Option<ResponseBody> {
        let contentType = this.respHead.get("Content-Type").getOrThrow()
        let contentLength: Int64 =  reportedContentLength()
        let readLimit: Int64
        if (contentLength > 0 ) {
            if ( allBuf.size() - parsedIndex < contentLength) {
                readLimit = contentLength + parsedIndex - allBuf.size() + 1
                var readBuf: Array<Byte> = Array<Byte>(readLimit, item: 0)
                let lenNum: Int64 =this.readBytesToBuffer(readBuf)
                this.allBuf.write(readBuf.slice( 0, lenNum))
            }
        } else if (contentLength < 0) {
            readLimit = 4096
            var bodyItemIndex = this.parsedIndex
            var readBuf: Array<Byte> = Array<Byte>(readLimit, item: 0)
            var read: Int64 = 0
            while (true) {
                var read: Int64 = this.readBytesToBuffer(readBuf)
                this.allBuf.write(readBuf.slice(0, read))
                let crlfCrlfIndex = indexOf(this.allBuf.bytes(), CRLF_CRLF, start: bodyItemIndex)
                if (bodyItemIndex == this.parsedIndex) {
                    bodyItemIndex -= CRLF_CRLF.size()
                }
                match (crlfCrlfIndex) {
                    case Some(x) =>
                        break
                    case None =>
                        bodyItemIndex += read
                        continue
                }
            }
        } else if (contentLength == 0) {
            return None
        }
        return  ResponseBody(contentType, contentLength, parseBody())
    }

    /**
     * The Function is parseBody
     *
     * @return Type of StringStream
     * @since 0.29.3
     */
    private func parseBody() : ByteArrayStream {
        let byteBuf = this.allBuf.bytes()
        if(reportedContentLength() != -1) {
            if ( this.parsedIndex == byteBuf.size()) {
                return ByteArrayStream(0)
            }
            let contentLength = reportedContentLength()
            var body = ByteArrayStream(contentLength)
            body.write(byteBuf.slice(this.parsedIndex, byteBuf.size() - this.parsedIndex))
            return body
        } else {
            var itemBody = Array<Byte>(byteBuf.size() - this.parsedIndex, item: 0)
            var itemIndex = 0
            var chunkStart = this.parsedIndex
            do {
                var crlfIndex = match (indexOf(byteBuf, CRLF, start: chunkStart)) {
                    case Some(x) => x
                    case None => throw Exception("chunked data is invalid:")
                }
                var chunkLenStr = String.fromUtf8(byteBuf.slice(chunkStart, crlfIndex - chunkStart), isAscii: true)
                var chunkLen = match(parseUInt64("0x"+chunkLenStr)) {
                    case Some (x) => Int64(x)
                    case None => throw Exception("header data is invalid:")
                }
                if (chunkLen == 0) {
                    break
                }
                if(crlfIndex + 2 + chunkLen > byteBuf.size()) {
                    break
                }
                let bufferSlice = byteBuf.slice(crlfIndex+2, chunkLen)
                bufferSlice.copyTo(itemBody, 0, itemIndex, chunkLen)
                itemIndex += chunkLen
                chunkStart = crlfIndex + 2 + chunkLen + 2
            } while (true)
            var body = ByteArrayStream(itemBody.size())
            body.write(itemBody)
            return body
        }
    }

     /*
      * The Function is readBytesToBuffer
      *
      * @param readBuf of Array<Byte>
      *
      * @return Type of Int64
      * @since 0.29.3
      */
     private func readBytesToBuffer(readBuf: Array<Byte>): Int64 {
        return match(readTimeout){
               case Some(time) =>
                   return  this.realConnection.getSocket().getOrThrow().read(readBuf, time)
               case None =>
                   return  this.realConnection.getSocket().getOrThrow().read(readBuf)
       }
    }

    /*
     * The Function is parseHead
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    private func parseHead(): ResponseBuilder {
        let responseBuilder: ResponseBuilder  = ResponseBuilder()
        var statusCode: Int64 = 200
        if (this.parsedIndex == 0) {
            var crlfIndex = match(indexOf(this.allBuf.bytes(), CRLF, start: 0)) {
                case Some(i) =>
                    this.parsedIndex = i+2
                    i
                case None =>
                    throw ProtocolException("no head")
            }
            var protoEndIndex = match (indexOf(this.allBuf.bytes(), SP, start: 0)) {
                case Some(i) => i
                case None => throw ProtocolException("header data is invalid: ")
            }
            var statusCodeEndIndex = match (indexOf(this.allBuf.bytes(), SP, start: protoEndIndex + 1)) {
                case Some(i) => i
                case None => throw ProtocolException("header data is invalid: ")
            }
            var proto = String.fromUtf8(this.allBuf.bytes().slice(0, protoEndIndex), isAscii: true)
            if (!proto.startsWith("HTTP/1.")) {
                if((proto == "ICY ")) {
                   proto = "http/1.0"
                } else {
                    throw ProtocolException("Unexpected proto: " + "${proto}")
                }
            }
            var messageIndex = match (indexOf(this.allBuf.bytes(), SP, start: protoEndIndex+1)) {
                case Some(i) => i
                case None => throw ProtocolException("header data is invalid: ")
            }
            let status = String.fromUtf8(this.allBuf.bytes().slice(protoEndIndex+1,
                            crlfIndex - protoEndIndex - 1), isAscii: true)
            responseBuilder.message(String.fromUtf8(this.allBuf.bytes().slice(messageIndex+1,
                            crlfIndex- messageIndex-1), isAscii: true))
            if (statusCodeEndIndex > crlfIndex) {
                statusCode = match (parseInt64(status)) {
                    case Some(x) => x
                    case None => throw ProtocolException("statusCode is invalid: ${status}")
                }
            } else {
                var itemStr = String.fromUtf8(this.allBuf.bytes().slice(protoEndIndex + 1,
                    statusCodeEndIndex - protoEndIndex - 1), isAscii: true)
                statusCode = match (parseInt64(itemStr)) {
                    case Some (x) => x
                    case None => throw ProtocolException("statusCode is invalid: ${itemStr}")
                }
            }
            responseBuilder.protocol(Protocol.get(proto)).code(statusCode)
        }
        doLoopHeader(responseBuilder)
        res = responseBuilder
        return responseBuilder
    }

    private func doLoopHeader(responseBuilder: ResponseBuilder) {
        while (true) {
            match (indexOf(this.allBuf.bytes(),CRLF, start: this.parsedIndex)) {
                case Some(i) =>
                    if (i == this.parsedIndex) {
                        state = STATE_OPEN_RESPONSE_BODY
                        this.parsedIndex = i + 2
                        break
                    }
                    var colonIndex = indexOf(this.allBuf.bytes(), b":", start: this.parsedIndex) ?? -1
                    if (colonIndex == -1 || colonIndex > i) {
                        throw Exception("header data is invalid:")
                    }
                    var key = String.fromUtf8(this.allBuf.bytes().slice(this.parsedIndex, colonIndex - this.parsedIndex), isAscii: true)
                    var val = String.fromUtf8(trim(this.allBuf.bytes().slice(colonIndex + 1, i - colonIndex - 1),SP), isAscii: true)
                    this.respHead.set(key, val)
                    responseBuilder.addHeader(key,val)
                    this.parsedIndex = i+2
                case None => ()
            }
        }
    }

    /**
     * The Function is getConnection
     *
     * @return Type of Connection
     * @since 0.30.4
     */
    public func getConnection(): Connection {
        return this.realConnection
    }

    /**
     * The Function is cancel
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func cancel(): Unit {
        this.realConnection.cancel()
    }
}

/**
 * The class is Http2ExchangeCodec inherited from ExchangeCodec
 * @author luoyukai4
 * @since 0.29.3
 */
public class Http2ExchangeCodec <: ExchangeCodec{
    private var connection: Connection
    private var realConnection: H2ClientConn
    private var respHead: Header = Header()
    private var response: ?H2Response = None

    /*
     * The Function is init constructor
     *
     * @param connection of Connection
     * @param realConnection of H2ClientConn
     * @since 0.30.4
     */
    init(connection: Connection, realConnection: H2ClientConn) {
        this.connection = connection
        this.realConnection = realConnection
    }


    /**
     * The Function is reportedContentLength
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func reportedContentLength(): Int64{
        match (this.respHead.get("Content-Length")) {
            case Some(s) =>
            match (parseInt64(s)) {
                case Some(n) => return n
                case None =>
                    throw HttpException("Content-Length is invalid: ${s}.")
            }
            case None => return response.getOrThrow().contentLength
        }
    }

    /**
     * The Function is write
     *
     * @param request of Request
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func write(request: Request): Unit {
        let req4cj = request.toHttpRequest()
        let res: H2Response = realConnection.doRequest(H2Request(req4cj))
        respHead = res.header
        response = res
    }


    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.30.4
     */
    public func readResponseHeaders(): ResponseBuilder {
        match(response) {
            case Some(h2resp) =>
                return Response.builder().protocol(Protocol.get(h2resp.proto)).code(h2resp.statusCode)
                    .header(h2resp.header.clone())
            case None =>
                throw Exception("invoke write first")
        }
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of Option<ResponseBody>
     * @since 0.30.4
     */
    public func openResponseBody(): Option<ResponseBody> {
        match(response) {
            case Some(h2resp) =>
                let contentLength =  reportedContentLength()
                if ( contentLength == 0){
                    return None
                }
                return ResponseBody(h2resp.header.get("Content-Type") ?? "", contentLength,
                    (h2resp.body as ByteArrayStream).getOrThrow())
            case None => throw Exception("invoke write first")
        }
    }

    /**
     * The Function is getConnection
     *
     * @return Type of Connection
     * @since 0.30.4
     */
    public func getConnection(): Connection {
        return this.connection
    }

    /**
     * The Function is cancel
     *
     * @return Type of Unit
     * @since 0.30.4
     */
    public func cancel(): Unit {
        this.realConnection.connState = ConnectionState.CLOSE
    }
}