/**
 * @file
 * The file declares the simple GET fast path.
 */

package httpclient4cj

internal import std.io.*
internal import std.net.*
internal import std.time.*

/**
 * 轻量响应头载体：只保留构建 Response 所需的字段，避免 ResponseBuilder 分配。
 */
class FastPathHead {
    let protocol: Protocol
    let code: Int64
    let message: String
    let header: Header
    // 解析响应头时一次性提取的高频字段，避免后续重复哈希查找
    let contentType: String
    let contentLength: Int64
    let chunked: Bool
    let gzipEncoded: Bool
    let connectionClose: Bool

    init(
        protocol: Protocol,
        code: Int64,
        message: String,
        header: Header,
        contentType: String,
        contentLength: Int64,
        chunked: Bool,
        gzipEncoded: Bool,
        connectionClose: Bool
    ) {
        this.protocol = protocol
        this.code = code
        this.message = message
        this.header = header
        this.contentType = contentType
        this.contentLength = contentLength
        this.chunked = chunked
        this.gzipEncoded = gzipEncoded
        this.connectionClose = connectionClose
    }
}

/**
 * 构造快路径请求字节：请求行 + 原始头 + BridgeInterceptor 会补充的默认头。
 *
 * @return 第一个元素为可直接写入 socket 的字节；第二个元素表示是否由客户端透明添加了
 *         Accept-Encoding: gzip（响应需要透明解压）。
 */
func buildFastPathRequestBytes(request: Request): (Array<Byte>, Bool) {
    let buffer = StringBuilder()
    buffer.append(RequestLine.get(request))
    buffer.append("\r\n")

    let headers = request.getHeaders()
    let count = headers.fieldCount()
    for (i in 0..count) {
        buffer.append(headers.fieldNameAt(i))
        buffer.append(": ")
        let values = headers.fieldValuesAt(i)
        for (j in 0..values.size) {
            if (j > 0) {
                buffer.append(";")
            }
            buffer.append(values[j])
        }
        buffer.append("\r\n")
    }

    var transparentGzip = false

    if (request.getHeader("Host", "") == "") {
        buffer.append("host: ")
        buffer.append(request.getUrl().hostName)
        buffer.append("\r\n")
    }
    if (request.getHeader("Connection", "") == "") {
        buffer.append("connection: Keep-Alive\r\n")
    }
    if (request.getHeader("Accept-Encoding", "") == "" && request.getHeader("Range", "") == "") {
        transparentGzip = true
        buffer.append("accept-encoding: gzip\r\n")
    }
    if (request.getHeader("User-Agent", "") == "") {
        buffer.append("user-agent: httpclient4cj\r\n")
    }

    buffer.append("\r\n")
    return (buffer.toString().toUtf8Array(), transparentGzip)
}

/**
 * 快路径响应头元信息：解析原始头块时一次性提取，避免为构造 Header 付出对象分配。
 */
class FastHeaderMeta {
    var contentType: String = ""
    var contentLength: Int64 = -1
    var chunked: Bool = false
    var gzipEncoded: Bool = false
    var connectionClose: Bool = false
    var contentTypeCount: Int64 = 0
    var contentLengthCount: Int64 = 0
    var transferEncodingCount: Int64 = 0
    var contentEncodingCount: Int64 = 0
    var connectionCount: Int64 = 0
}

func fastHeaderNameIs(raw: String, start: Int64, colon: Int64, expected: String): Bool {
    if (colon - start != expected.size) {
        return false
    }
    for (i in 0..expected.size) {
        var c = raw[start + i]
        if (c >= 0x41u8 && c <= 0x5Au8) {
            c += 0x20u8
        }
        if (c != expected[i]) {
            return false
        }
    }
    return true
}

func trimFastValueRange(raw: String, start: Int64, end: Int64): (Int64, Int64) {
    var s = start
    var e = end
    while (s < e) {
        let b = raw[s]
        if (b != 0x20u8 && b != 0x09u8) {
            break
        }
        s++
    }
    while (e > s) {
        let b = raw[e - 1]
        if (b != 0x20u8 && b != 0x09u8) {
            break
        }
        e--
    }
    return (s, e)
}

func fastHeaderNameValid(raw: String, start: Int64, colon: Int64): Bool {
    if (colon <= start) {
        return false
    }
    for (i in start..colon) {
        if (!isHttpTokenByte(raw[i])) {
            return false
        }
    }
    return true
}

func fastHeaderValueValid(raw: String, start: Int64, end: Int64): Bool {
    for (i in start..end) {
        let b = raw[i]
        if ((b < 0x20u8 && b != 0x09u8) || b == 0x7Fu8) {
            return false
        }
    }
    return true
}

func scanFastHeaderLine(meta: FastHeaderMeta, raw: String, start: Int64, end: Int64): Unit {
    var colon = -1
    var i = start + 1
    while (i < end) {
        if (raw[i] == 0x3Au8) {
            colon = i
            break
        }
        i++
    }
    if (colon > start) {
        // 伪头（":xxx"）走 Header 的独立存储，这里不提取元信息
        if (raw[start] == 0x3Au8) {
            return
        }
        if (!fastHeaderNameValid(raw, start, colon)) {
            throw HttpException("Invalid header name: ${raw.substring(start, colon - start)}.")
        }
        let (valueStart, valueEnd) = trimFastValueRange(raw, colon + 1, end)
        if (valueStart == valueEnd) {
            return
        }
        if (!fastHeaderValueValid(raw, valueStart, valueEnd)) {
            throw HttpException("Invalid header value: ${raw.substring(valueStart, valueEnd - valueStart)}.")
        }
        let value = trimHeaderValue(raw.substring(colon + 1, end - colon - 1))
        if (value.isEmpty()) {
            return
        }
        if (fastHeaderNameIs(raw, start, colon, "content-length")) {
            meta.contentLengthCount++
            if (meta.contentLengthCount == 1) {
                meta.contentLength = Int64.tryParse(value) ?? -1
            } else {
                meta.contentLength = -1
            }
        } else if (fastHeaderNameIs(raw, start, colon, "content-type")) {
            if (meta.contentTypeCount == 0) {
                meta.contentType = value
            } else {
                meta.contentType = meta.contentType + "; " + value
            }
            meta.contentTypeCount++
        } else if (fastHeaderNameIs(raw, start, colon, "transfer-encoding")) {
            meta.transferEncodingCount++
            meta.chunked = meta.transferEncodingCount == 1 && equalsIgnoreCase(value, "chunked")
        } else if (fastHeaderNameIs(raw, start, colon, "content-encoding")) {
            meta.contentEncodingCount++
            meta.gzipEncoded = meta.contentEncodingCount == 1 && equalsIgnoreCase(value, "gzip")
        } else if (fastHeaderNameIs(raw, start, colon, "connection")) {
            meta.connectionCount++
            meta.connectionClose = meta.connectionCount == 1 && equalsIgnoreCase(value, "close")
        }
    } else if (end > start) {
        // 与通用解析保持一致：非法头行在读取阶段就失败
        addLenientFast(Header(), raw.substring(start, end - start))
    }
}

/**
 * 扫描原始响应头块，只提取 body 构造与回退判定需要的字段；Header 本身延迟到被访问时再解析。
 */
func scanFastHeaders(raw: String): FastHeaderMeta {
    let meta = FastHeaderMeta()
    var pos = 0
    var lineStart = 0
    while (pos < raw.size) {
        if (raw[pos] == 0x0Du8 && pos + 1 < raw.size && raw[pos + 1] == 0x0Au8) {
            scanFastHeaderLine(meta, raw, lineStart, pos)
            pos += 2
            lineStart = pos
        } else {
            pos++
        }
    }
    if (lineStart < raw.size) {
        scanFastHeaderLine(meta, raw, lineStart, raw.size)
    }
    return meta
}

/**
 * 这些状态码需要通用链的 redirect / auth / retry / 1xx 处理，不能由快路径直接返回。
 */
func needsGeneralChain(code: Int64): Bool {
    return code < 200 || code == 205 || (code >= 300 && code < 400 && code != 304) || code == 408 ||
        code == 503
}

/**
 * 简单 GET 快路径。
 *
 * 只处理可安全重放的请求：门控不通过或响应形态不受支持时返回 None，由调用方回退到
 * 通用拦截器链。返回 Some 时响应体/连接复用语义与通用链完全一致。
 */
class FastPath {
    static func execute(request: Request, transmitter: Transmitter): Option<Response> {
        try {
            let wire = request.getFastPathWire()
            transmitter.prepareToConnect(request)

            if (transmitter.isCanceled()) {
                throw HttpException("Canceled")
            }

            let exchange = transmitter.newExchangeForFastPath()

            // 快路径只支持 HTTP/1.1 明文连接；其他协议直接回退
            var http1Codec: Option<Http1ExchangeCodec> = Option<Http1ExchangeCodec>.None
            match (exchange.codec) {
                case codec: Http1ExchangeCodec => http1Codec = Option<Http1ExchangeCodec>.Some(codec)
                case _ =>
                    closeForFallback(transmitter)
                    return Option<Response>.None
            }
            let codec = http1Codec.getOrThrow()

            codec.writeRequestBytes(wire[0])
            exchange.noRequestBody()
            let sentRequestMillis = DateTime.now().toUnixTimeStamp().toMilliseconds()
            exchange.finishRequest()

            let head = codec.readResponseHeadForFastPath()

            // 仅对需要 redirect/auth/retry 或协议升级的状态码回退；
            // 其余（200/204/304/206/4xx/5xx 等）在快路径内收尾，避免同一请求发送两次。
            if (needsGeneralChain(head.code)) {
                closeForFallback(transmitter)
                return Option<Response>.None
            }

            var source: Source
            try {
                source = codec.openResponseBodySourceFast(request.getUrl(), head.contentLength, head.chunked)
            } catch (e: HttpException) {
                exchange.fastResponseBodyFailed(e)
                throw e
            }
            var body = ResponseBody(
                head.contentType,
                head.contentLength,
                ResponseBodySource(source, exchange, head.contentLength)
            )
            if (head.connectionClose) {
                exchange.noNewExchangesOnConnection()
            }
            let receivedResponseMillis = DateTime.now().toUnixTimeStamp().toMilliseconds()
            var header = head.header

            // 与 BridgeInterceptor 的透明 gzip 处理保持一致
            if (wire[1] && head.gzipEncoded) {
                let strippedHeader = head.header.clone()
                strippedHeader.remove("Content-Encoding")
                strippedHeader.remove("Content-Length")
                body = ResponseBody(head.contentType, -1, OkGzipSource(body.getSource()))
                header = strippedHeader
            }
            let response = Response(
                request,
                head.protocol,
                head.code,
                head.message,
                header,
                Option<ResponseBody>.Some(body),
                Option<Exchange>.Some(exchange),
                sentRequestMillis,
                receivedResponseMillis
            )
            return Option<Response>.Some(response)
        } catch (e: Exception) {
            closeForFallback(transmitter)
            if (transmitter.isCanceled()) {
                throw HttpException("Canceled")
            }
            // 仅当通用链本就会重试时才回放，避免连接超时等失败被重放成双倍耗时
            if (canReplayAfterError(e, transmitter)) {
                return Option<Response>.None
            }
            match (e) {
                case routeError: RouteException => throw routeError.getFirstConnectException()
                case _ => throw e
            }
        }
    }

    /**
     * 与 RetryAndFollowUpInterceptor.recover 的可重试判定保持一致：
     * 协议错误不可重试；连接类错误仅超时且仍有可用路由时可重试。
     */
    private static func canReplayAfterError(e: Exception, transmitter: Transmitter): Bool {
        let retryable = match (e) {
            case _: ProtocolException => false
            case routeError: RouteException =>
                let last = routeError.getLastConnectException()
                match (last) {
                    case connectError: ConnectException =>
                        connectError.contain is SocketTimeoutException
                    case _: ProtocolException => false
                    case _ => true
                }
            case _: HttpException => true
            case _ => false
        }
        if (!retryable) {
            return false
        }
        try {
            return transmitter.canRetry()
        } catch (ignore: Exception) {
            return false
        }
    }

    /**
     * 丢弃本次快路径尝试占用的连接，保证回退到通用链时不会复用半写入/半读取的 socket。
     */
    private static func closeForFallback(transmitter: Transmitter): Unit {
        match (transmitter.connection) {
            case Some(connection) =>
                connection.noExchanges()
                try {
                    Util.closeQuietly(connection.getSocket())
                } catch (e: Exception) {
                    ()
                }
            case None => ()
        }
        try {
            if (transmitter.hasExchange()) {
                transmitter.exchangeDoneDueToException()
            }
        } catch (e: Exception) {
            ()
        }
    }
}
