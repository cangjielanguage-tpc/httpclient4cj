/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the ExchangeCodec class.
 */

package httpclient4cj


/* let member CRLF type is Array<Byte> */
let CRLF: Array<Byte> = "\r\n".toArray()

/* let member SP */
let SP = " ".toArray()

/* let member TRIM_BYTE type is Array<Byte> */
let TRIM_BYTE: Array<Byte> = SP
let CRLF_STR: String = "\r\n"
let CHAR_ZERO: UInt32 = 48
let UInt64ToHex: Array<UInt8> = "0123456789abcdef".toArray()

/**
 * The class is Http1ExchangeCodec
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Http1ExchangeCodec <: ExchangeCodec {
    public static let CRLF: String = "\r\n"

    /* let member STATE_IDLE type is Int64 */
    static let STATE_IDLE: Int64 = 0 // Idle connections are ready to write request headers.

    /* let member STATE_OPEN_REQUEST_BODY type is Int64 */
    static let STATE_OPEN_REQUEST_BODY: Int64 = 1

    /* let member STATE_WRITING_REQUEST_BODY type is Int64 */
    static let STATE_WRITING_REQUEST_BODY: Int64 = 2

    /* let member STATE_READ_RESPONSE_HEADERS type is Int64 */
    static let STATE_READ_RESPONSE_HEADERS: Int64 = 3

    /* let member STATE_OPEN_RESPONSE_BODY type is Int64 */
    static let STATE_OPEN_RESPONSE_BODY: Int64 = 4

    /* let member STATE_READING_RESPONSE_BODY type is Int64 */
    private static let STATE_READING_RESPONSE_BODY: Int64 = 5

    /* let member STATE_CLOSED type is Int64 */
    static let STATE_CLOSED: Int64 = 6

    /* let member HEADER_LIMIT type is Int64 */
    private static let HEADER_LIMIT: Int64 = 256 * 1024

    /* var member realConnection type is Connection */
    private var realConnection: Connection

    /* var member state type is Int64 */
    var state: Int64 = STATE_IDLE

    /* var member client type is HttpClient */
    var client: HttpClient
    let sink: BufferedOutputStream<OutputStream>
    let source: OkBuffer
    private var headerLimit: Int64 = HEADER_LIMIT
    var trailers: Header = Header()

    /**
     * The Function is init constructor
     *
     * @param client of HttpClient
     * @param realConnection of Connection
     * @since 0.29.3
     */
    public init(
        client: HttpClient,
        realConnection: Connection,
        source: OkBuffer,
        sink: BufferedOutputStream<OutputStream>
    ) {
        this.client = client
        this.realConnection = realConnection
        this.source = source
        this.sink = sink
    }

    private func newKnownLengthSink(): Sink {
        if (state != STATE_OPEN_REQUEST_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_WRITING_REQUEST_BODY
        return KnownLengthSink(this)
    }

    private func newChunkedSink() {
        if (state != STATE_OPEN_REQUEST_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_WRITING_REQUEST_BODY
        return ChunkedSink(this)
    }

    private func newFixedLengthSource(length: Int64) {
        if (state != STATE_OPEN_RESPONSE_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_READING_RESPONSE_BODY
        return FixedLengthSource(length, this)
    }

    private func newChunkedSource(url: URL): Source {
        if (state != STATE_OPEN_RESPONSE_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_READING_RESPONSE_BODY
        return ChunkedSource(url, this)
    }

    private func newUnknownLengthSource(): Source {
        if (state != STATE_OPEN_RESPONSE_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_READING_RESPONSE_BODY
        realConnection.noExchanges()
        return UnknownLengthSource(this)
    }

    public func flushRequest(): Unit {
        try {
            sink.flush()
        } catch (e: Exception) {
            realConnection.noExchanges()
            throw e
        }
    }

    public func finishRequest(): Unit {
        try {
            sink.flush()
        } catch (e: Exception) {
            realConnection.noExchanges()
            throw e
        }
    }

    public func getTrailers() {
        if (state != STATE_CLOSED) {
            throw IllegalStateException("too early; can't read the trailers yet")
        }
        return trailers
    }

    public func writeRequestHeaders(request: Request): Unit {
        if (state != STATE_IDLE) {
            throw IllegalStateException("state: ${state}")
        }
        let headers = request.getHeaders()
        let bytes = buildRequestBytes(headers, RequestLine.get(request))
        sink.write(bytes)
        state = STATE_OPEN_REQUEST_BODY
    }

    private func buildRequestBytes(headers: Header, requestLine: String): Array<Byte> {
        var buffer: StringBuilder = StringBuilder()
        buffer.append(requestLine)
        buffer.append(CRLF)
        let count = headers.fieldCount()
        for (i in 0..count) {
            buffer.append(headers.fieldNameAt(i))
            buffer.append(": ")
            let v = headers.fieldValuesAt(i)
            for (j in 0..v.size) {
                if (j > 0) {
                    buffer.append(";")
                }
                buffer.append(v[j])
            }
            buffer.append(CRLF)
        }
        buffer.append(CRLF_STR)
        return buffer.toString().toUtf8Array()
    }

    public func writeRequest(headers: Header, requestLine: String): Unit {
        if (state != STATE_IDLE) {
            throw IllegalStateException("state: ${state}")
        }

        var buffer: StringBuilder = StringBuilder()
        buffer.append(requestLine)
        buffer.append(CRLF)

        let count = headers.fieldCount()
        for (i in 0..count) {
            buffer.append(headers.fieldNameAt(i))
            buffer.append(": ")
            let v = headers.fieldValuesAt(i)
            for (j in 0..v.size) {
                if (j > 0) {
                    buffer.append(";")
                }
                buffer.append(v[j])
            }
            buffer.append(CRLF)
        }

        buffer.append(CRLF_STR)
        sink.write(buffer.toString().toUtf8Array())
        state = STATE_OPEN_REQUEST_BODY
    }

    /**
     * 快路径：写入已缓存的请求行+请求头字节，跳过 Header 遍历与字符串拼接。
     */
    func writeRequestBytes(bytes: Array<Byte>): Unit {
        if (state != STATE_IDLE) {
            throw IllegalStateException("state: ${state}")
        }
        sink.write(bytes)
        state = STATE_OPEN_REQUEST_BODY
    }

    /**
     * 快路径：读取状态行与响应头，使用轻量结构承载，避免 ResponseBuilder 分配。
     */
    func readResponseHeadForFastPath(): FastPathHead {
        if (state != STATE_OPEN_REQUEST_BODY && state != STATE_READ_RESPONSE_HEADERS) {
            throw IllegalStateException("state: ${state}")
        }
        let statusLine = StatusLine.parse(readHeaderLine())
        let (rawHeaders, headerBytes) = source.readHeaderBlockStrict(headerLimit)
        headerLimit -= headerBytes
        let header = Header(rawHeaders)
        let meta = scanFastHeaders(rawHeaders)
        // 与通用路径 checkResponse 对齐：204 + 非零 Content-Length 直接抛协议异常
        if (statusLine.code == HttpStatusCode.STATUS_NO_CONTENT && !meta.chunked && meta.contentLength > 0) {
            throw ProtocolException("HTTP 204 had non-zero Content-Length: ${meta.contentLength}")
        }
        // chunked 解码后的长度与 Content-Length 无关；204/304 不允许 body
        if (meta.chunked) {
            meta.contentLength = -1
        }
        if (statusLine.code == HttpStatusCode.STATUS_NO_CONTENT ||
            statusLine.code == HttpStatusCode.STATUS_NOT_MODIFIED) {
            meta.contentLength = 0
            meta.chunked = false
            meta.gzipEncoded = false
        }
        let head = FastPathHead(
            statusLine.protocol,
            statusLine.code,
            statusLine.message,
            header,
            meta.contentType,
            meta.contentLength,
            meta.chunked,
            meta.gzipEncoded,
            meta.connectionClose
        )
        if (statusLine.code == HttpStatusCode.STATUS_CONTINUE) {
            state = STATE_READ_RESPONSE_HEADERS
        } else {
            state = STATE_OPEN_RESPONSE_BODY
        }
        return head
    }

    /**
     * The Function is readResponseHeaders
     *
     * @return Type of ResponseBuilder
     * @since 0.29.3
     */
    public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder> {
        if (state != STATE_OPEN_REQUEST_BODY && state != STATE_READ_RESPONSE_HEADERS) {
            throw IllegalStateException("state: ${state}")
        }

        let responseBuilder: ResponseBuilder = Response.builder()
        let line: String = readHeaderLine()
        let statusLine: StatusLine = StatusLine.parse(line)
        responseBuilder.protocol(statusLine.protocol).code(statusLine.code).message(statusLine.message).header(
            readHeaders())

        if (expectContinue && statusLine.code == HttpStatusCode.STATUS_CONTINUE) {
            return None
        } else if (statusLine.code == HttpStatusCode.STATUS_CONTINUE) {
            state = STATE_READ_RESPONSE_HEADERS
            return responseBuilder
        }

        state = STATE_OPEN_RESPONSE_BODY
        return responseBuilder
    }

    private func readHeaderLine(): String {
        let line = source.readUtf8LineStrict(headerLimit)
        headerLimit -= line.size
        return line
    }

    func readHeaders(): Header {
        let header: Header = Header()

        while (true) {
            var line = readHeaderLine()
            if (line.size == 0) {
                break
            }
            addLenient(header, line)
        }
        return header
    }

    public func createRequestBody(request: Request): Sink {
        let contentLength: Int64 = match (request.getBody()) {
            case Some(v) => v.getContentLength()
            case None => throw ProtocolException("no request body")
        }

        if (equalsIgnoreCase("chunked", request.getHeader("Transfer-Encoding", ""))) {
            return newChunkedSink()
        }

        if (contentLength != -1) {
            return newKnownLengthSink()
        }

        throw IllegalStateException("Cannot stream a request body without chunked encoding or a known content length!")
    }

    /*
     * The Function is reportedContentLength
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    public func reportedContentLength(response: Response): Int64 {
        if (!hasBody(response)) {
            return 0
        }

        if (equalsIgnoreCase("chunked", response.getHeader("Transfer-Encoding", ""))) {
            return -1
        }

        match (response.getHeader("Content-Length")) {
            case Some(s) => match (Int64.tryParse(s)) {
                case Some(n) => return n
                case None => return -1
            }
            case None => return -1
        }
    }
    public func openResponseBodySource(response: Response): Source {
        if (!hasBody(response)) {
            return newFixedLengthSource(0)
        }

        if (equalsIgnoreCase("chunked", response.getHeader("Transfer-Encoding", ""))) {
            return newChunkedSource(response.getRequest().getUrl())
        }

        let contentLength: Int64 = contentLength(response)

        if (contentLength != -1) {
            return newFixedLengthSource(contentLength)
        }

        return newUnknownLengthSource()
    }

    /**
     * 快路径：按已解析的 Content-Length/Transfer-Encoding 直接选择 body source。
     */
    func openResponseBodySourceFast(url: URL, contentLength: Int64, chunked: Bool): Source {
        if (chunked) {
            return newChunkedSource(url)
        }
        if (contentLength != -1) {
            return newFixedLengthSource(contentLength)
        }
        return newUnknownLengthSource()
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

    func responseBodyComplete() {
        if (state == STATE_CLOSED) {
            return
        }

        if (state != STATE_READING_RESPONSE_BODY) {
            throw IllegalStateException("state: ${state}")
        }

        state = STATE_CLOSED
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
