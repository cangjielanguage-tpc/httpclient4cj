/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ExchangeFinder class.
 */
package okhttp


/**
 * The class is ExchangeFinder
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ExchangeFinder {
    /* var member transmitter type is Transmitter */
    private var transmitter: Transmitter
    /* var member address type is Address */
    private var address: Address
    /* var member call type is Call */
    private var call: Call
    /* var member connectionPool type is ConnectionPool */
    private var connectionPool: ConnectionPool
    /* var member routeSelector type is RouteSelector */
    private var routeSelector: RouteSelector
    /* var member connectingConnection type is Option<Connection> */
    private var connectingConnection:Option<Connection> = None

    /**
     * The Function is init constructor
     *
     * @param transmitter of Transmitter
     * @param connectionPool of ConnectionPool
     * @param address of Address
     * @param call of Call
     * @since 0.29.3
     */
    public init (transmitter: Transmitter, connectionPool: ConnectionPool, address: Address, call: Call) {
        this.transmitter = transmitter
        this.connectionPool = connectionPool
        this.call = call
        this.address = address
        this.routeSelector = RouteSelector(address, call)
    }

    /**
     * The Function is find
     *
     * @param client of OkHttpClient
     * @param chain of Chain
     * @param doExtensiveHealthChecks of Bool
     *
     * @return Type of ExchangeCodec
     * @since 0.29.3
     */
    public func find(client: OkHttpClient, chain: Chain, doExtensiveHealthChecks: Bool): ExchangeCodec {
        let conn: Connection = findHealthyConnection()
        return conn.newCodec(client, chain)
    }

    /*
     * The Function is findHealthyConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findHealthyConnection(): Connection {
        let candidate: Connection  =  findConnection()
        return candidate

    }


    /*
     * The Function is findConnection
     *
     * @return Type of Connection
     * @since 0.29.3
     */
    private func findConnection(): Connection {
        // TODO Connection reuse
        var toClose: Option<Socket>
        var result: Option<Connection> = Option<Connection>.None
        synchronized (connectionPool.mutex) {
            if (transmitter.isCanceled()) {
                throw Exception("Transmitter has Canceled")
            }
            match(transmitter.connection) {
                case Some(conn) =>
                    toClose = transmitter.releaseConnectionNoEvents()
                    result = transmitter.connection
                case _ =>
                    toClose = Option<Socket>.None
                    // Attempt to get a connection from the pool.
                    // TODO route
                    if (connectionPool.transmitterAcquirePooledConnection(address,transmitter)){
                        result = transmitter.connection
                    }
            }
        }
        Util.closeQuietly(toClose)
        let ret: Connection = match (result) {
            case Some(r) => return  r
            case None =>
                let conn = Connection(connectionPool, routeSelector.next())
                conn.connect()
                connectingConnection = Option<Connection>.Some(conn)
                return conn
        }
        return ret
    }
}

/**
 * The class is Exchange
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Exchange {

    /** var member transmitter type is Transmitter */
    public var transmitter: Transmitter
    /** var member call type is Call */
    public var call: Call
    /** var member finder type is ExchangeFinder */
    public var finder: ExchangeFinder
    /** var member codec type is ExchangeCodec */
    public var codec: ExchangeCodec

    /**
     * The Function is init constructor
     *
     * @param transmitter of Transmitter
     * @param call of Call
     * @param finder of ExchangeFinder
     * @param codec of ExchangeCodec
     * @since 0.29.3
     */
    public init (transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec) {
        this.transmitter = transmitter
        this.call = call
        this.finder = finder
        this.codec = codec
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
        codec.write(request)
    }

    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    public func readResponseHeaders(): ResponseBuilder {
        return codec.readResponseHeaders()
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of ResponseBody
     * @since 0.29.3
     */
    public func openResponseBody(): ResponseBody {
         return codec.openResponseBody()
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
 * The class is ExchangeCodec
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ExchangeCodec {

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
    /* var member clientoTimeDuration type is Option<Duration> */
    private var clientoTimeDuration: Option<Duration> = None
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

    /**
     * The Function is init constructor
     *
     * @param client of OkHttpClient
     * @param realConnection of Connection
     * @since 0.29.3
     */
    public init (client: OkHttpClient, realConnection: Connection) {
        this.client = client
        this.realConnection = realConnection
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
        let req4cj: http.Request =  request.toHttpRequest()
        var requestStream: StringStream = StringStream("")
        req4cj.write(requestStream)
        let reqMethod = request.method.toString()
        let writeBuf = requestStream.toString().toUtf8Array()
        let socket = this.realConnection.getSocket().getOrThrow()
        match (socket.write(writeBuf)) {
            case None =>
            socket.close()
            case Some(v) =>
            ()
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
        var lenNum: Int64 = this.ReadBytesToBuffer(readBuf)
        if (lenNum <= 0) {
            throw Exception()
        }
        this.allBuf.write(readBuf, 0, lenNum)
        return this.parseHead()
    }

    /*
     * The Function is reportedContentLength
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    private func reportedContentLength(): Int64{
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
            case None => return  0
        }
    }

    /**
     * The Function is openResponseBody
     *
     * @return Type of ResponseBody
     * @since 0.29.3
     */
    public func openResponseBody(): ResponseBody {
        let contentType = this.respHead.get("Content-Type").getOrThrow()
        let contentLength: Int64 =  reportedContentLength()
        let readLimit: Int64
        if (contentLength > 0 ) {
            if ( allBuf.size() - parsedIndex < contentLength) {
                readLimit = contentLength + parsedIndex - allBuf.size() + 1
                var readBuf: Array<Byte> = Array<Byte>(readLimit, item: 0)
                let lenNum: Int64 =this.ReadBytesToBuffer(readBuf)
                this.allBuf.write(readBuf, 0, lenNum)
            }
        } else if (contentLength < 0) {
            readLimit = 4096
            var bodyItemIndex = this.parsedIndex
            var readBuf: Array<Byte> = Array<Byte>(readLimit, item: 0)
            var read: Int64 = 0
            while (true) {
                var read: Int64 = this.ReadBytesToBuffer(readBuf)
                this.allBuf.write(readBuf, 0, read)
                let crlfCrlfIndex = this.allBuf.indexOf(CRLF_CRLF, start: bodyItemIndex)
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
            return  ResponseBody(contentType, contentLength, StringStream(""))
        }
        return  ResponseBody(contentType, contentLength, parseBody())
    }

    /**
     * The Function is parseBody
     *
     * @return Type of StringStream
     * @since 0.29.3
     */
    public func parseBody() : StringStream {

        if(reportedContentLength() != -1) {
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
                if(crlfIndex + 2 + chunkLen > this.allBuf.size()) {
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
                    let readTimeLen = this.realConnection.getSocket().getOrThrow().read(readBuf, time)
                    match (readTimeLen) {
                        case Some(v) => lenNum = v
                        case None => throw HttpException("Request Timeout.")
                    }
                case None =>
                    let readLen = this.realConnection.getSocket().getOrThrow().read(readBuf)
                    match (readLen) {
                        case Some(l) =>
                            lenNum = l
                        case None =>
                            lenNum = -1
                    }
            }
            return lenNum
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
            var crlfIndex = match(this.allBuf.indexOf(CRLF, start: 0)) {
                case Some(i) =>
                    this.parsedIndex = i+2
                    i
                case None =>
                    throw Exception("no head")
            }
            var protoEndIndex = match (this.allBuf.indexOf(SP, start: 0)) {
                case Some(i) => i
                case None => throw HttpException("header data is invalid: ")
            }
            var statusCodeEndIndex = match (this.allBuf.indexOf(SP, start: protoEndIndex + 1)) {
                case Some(i) => i
                case None => throw HttpException("header data is invalid: ")
            }
            let proto = String.fromUtf8(this.allBuf.slice(0, protoEndIndex), isAscii: true)
            let status = String.fromUtf8(this.allBuf.slice(protoEndIndex+1, crlfIndex - protoEndIndex - 1), isAscii: true)
            if (statusCodeEndIndex > crlfIndex) {
                statusCode = match (parseInt64(status)) {
                    case Some(x) => x
                    case None => throw Exception("statusCode is invalid: ${status}")
                }
            } else {
                var itemStr = String.fromUtf8(this.allBuf.slice(protoEndIndex + 1, statusCodeEndIndex - protoEndIndex - 1), isAscii: true)
                statusCode = match (parseInt64(itemStr)) {
                    case Some (x) => x
                    case None => throw Exception("statusCode is invalid: ${itemStr}")
                }
            }
            responseBuilder.protocol(Protocol.get(proto))
            .code(statusCode)

        }
        while (true) {
            match (this.allBuf.indexOf(CRLF, start: this.parsedIndex)) {
                case Some(i) =>
                    if (i == this.parsedIndex) {
                        state = STATE_OPEN_RESPONSE_BODY
                        this.parsedIndex = i + 2
                        break
                    }
                    var colonIndex = this.allBuf.indexOf(b":", start: this.parsedIndex) ?? -1
                    if (colonIndex == -1 || colonIndex > i) {
                        throw Exception("header data is invalid:")
                    }
                    var key = String.fromUtf8(this.allBuf.slice(this.parsedIndex, colonIndex - this.parsedIndex), isAscii: true)
                    var (valStart, valLength) = this.allBuf.trim(colonIndex + 1, i - colonIndex - 1, TRIM_BYTE)
                    var val = String.fromUtf8(this.allBuf.slice(valStart, valLength), isAscii: true)
                    this.respHead.set(key, val)
                    responseBuilder.addHeader(key,val)
                    this.parsedIndex = i+2
                case None => ()
            }
        }
        res = responseBuilder
        return responseBuilder
    }

}