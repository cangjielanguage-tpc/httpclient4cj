/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file The file declars the xxxx class.
 */

package httpclient4cj

let PREFACE: String = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"

/*
 * 对标 OkHttp Http2Connection.java (3.14.9) 的锁纪律注释:
 *
 * Internal state of this connection is guarded by 'muLock'. No blocking
 * operations may be performed while holding this lock!
 *
 * Socket writes are guarded by writer.mutex.
 *
 * Socket reads are unguarded but are only made by the reader thread.
 *
 * Certain operations (like newStream) need to synchronize on both the
 * writer.mutex (to do blocking I/O) and muLock (to create streams). Such
 * operations must synchronize on 'muLock' last. This ensures that we never
 * wait for a blocking operation while holding 'muLock'.
 */

/**
 * The class is H2Connection
 *
 * A connection hosts streams which can send and receive
 * data.
 *
 * @author luoyukai4
 * @since 0.34.3
 */
public class H2Connection {
    protected var socket: SocketClient
    protected var nextStreamID: UInt32 = 1
    protected let streams = ConcurrentHashMap<UInt32, H2Stream>()
    let muLock: Monitor = Monitor()

    let hpackEncode: Encoder = Encoder.newEncoder()

    public prop streamMap: ConcurrentHashMap<UInt32, H2Stream> {
        get() {
            return streams
        }
    }

    static let HTTP_CLIENT_WINDOW_SIZE = 16 * 1024 * 1024
    var httpSettings: Settings = Settings()
    let peerSettings: Settings = Settings()
    let writer: Http2Writer
    let reader: Http2Reader
    var bytesLeftInWriteWindow: Int64
    private var intervalPingsSent = 0
    private var intervalPongsReceived = 0
    private var degradedPingsSent = 0
    private var degradedPongsReceived = 0
    private var awaitPingsSent = 0
    private var awaitPongsReceived = 0
    static let INTERVAL_PING = 1
    static let DEGRADED_PING = 2
    static let AWAIT_PING = 3
    private var shutdown: Bool = false
    let listener: Option<Connection>
    var degradedPongDeadline: Int64 = DateTime.now().toUnixTimeStamp().toMilliseconds()
    var unacknowledgedBytesRead = 0

    public init(
        socket: SocketClient,
        sink: BufferedOutputStream<OutputStream>,
        source: OkBuffer,
        listener!: Option<Connection> = Option<Connection>.None
    ) {
        this.socket = socket
        this.listener = listener
        httpSettings.setting(Settings.INITIAL_WINDOW_SIZE, HTTP_CLIENT_WINDOW_SIZE)
        peerSettings.setting(Settings.INITIAL_WINDOW_SIZE, Settings.DEFAULT_INITIAL_WINDOW_SIZE)
        peerSettings.setting(Settings.MAX_FRAME_SIZE, INITIAL_MAX_FRAME_SIZE)
        bytesLeftInWriteWindow = peerSettings.getInitialWindowSize()
        nextStreamID += 2
        reader = Http2Reader(source)
        writer = Http2Writer(sink, hpackEncode)
    }

    /**
     * The Function is start
     *
     * Sends any initial frames and starts reading frames from the remote peer. This should be called
     * after init for all new connections.
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func start(): Unit {
        writer.connectionPreface()
        writer.settings(httpSettings)
        let windowSize = httpSettings.getInitialWindowSize()
        if (httpSettings.getInitialWindowSize() != Settings.DEFAULT_INITIAL_WINDOW_SIZE) {
            writer.windowUpdate(0, windowSize - Settings.DEFAULT_INITIAL_WINDOW_SIZE)
        }
        spawn {
            // 对标 OkHttp ReaderRunnable.execute (L662-680):
            // catch (HttpException) ≙ Java 的 catch (IOException) —— Http2Reader 已将
            // SocketException/SocketTimeoutException 统一转为 HttpException 上抛,
            // 任何读路径异常下 finally 的 close 清理链必达
            var connectionErrorCode: ErrorCode = INTERNAL_ERROR
            var streamErrorCode: ErrorCode = INTERNAL_ERROR
            var errorException: String = ""
            try {
                reader.readConnectionPreface(this)
                while (reader.nextFrame(false, this)) {}
                connectionErrorCode = ErrorCode.NO_ERROR
                streamErrorCode = ErrorCode.CANCEL
            } catch (e: HttpException) {
                errorException = e.message
                connectionErrorCode = ErrorCode.PROTOCOL_ERROR
                streamErrorCode = ErrorCode.PROTOCOL_ERROR
            } finally {
                close(connectionErrorCode, streamErrorCode, errorException)
                reader.source.close()
            }
        }
    }

    /**
     * The Function is openStreamCount
     *
     * Returns the number of open streams on this connection
     *
     * @return Type of Int64
     * @since 0.34.3
     */
    public func openStreamCount(): Int64 {
        synchronized(muLock) {
            return streams.size
        }
    }

    /**
     * Closes this connection. This cancels all open streams
     *
     * @since 0.34.3
     */
    public func close() {
        close(ErrorCode.NO_ERROR, ErrorCode.CANCEL, "")
    }

    func close(connectionCode: ErrorCode, streamCode: ErrorCode, cause: String) {
        // 对标 OkHttp Http2Connection.close (L471-510):
        // 断言不持有连接锁(仓颉无 holdsLock, 以调用方结构保证); 锁内只做快照并清空 map,
        // stream.close(含 socket 写)移到锁外, 消除持 muLock 等待 writer.mutex 的窗口。
        // catch 对标 Java 的 catch (IOException ignored): 仓颉中 SocketTimeoutException
        // 与 SocketException 无继承关系, 需一并捕获, 确保清理链必达。
        try {
            shutdownConn(connectionCode)
        } catch (ignored: HttpException | SocketException | SocketTimeoutException) {}

        let streamsToClose = ArrayList<H2Stream>()
        synchronized(muLock) {
            let arr = streamMap |> collectArray
            for (item in arr) {
                streamsToClose.add(item[1])
                streamMap.remove(item[0])
            }
        }

        if (streamsToClose.size > 0) {
            for (stream in streamsToClose) {
                try {
                    stream.close(streamCode, cause)
                } catch (ignored: HttpException | SocketException | SocketTimeoutException) {}
            }
        }

        try {
            writer.close()
        } catch (ignored: HttpException | SocketException | SocketTimeoutException) {}

        try {
            socket.close()
        } catch (ignored: HttpException | SocketException | SocketTimeoutException) {}
    }

    func removeStream(streamId: UInt32): Option<H2Stream> {
        // 对标 OkHttp Http2Connection.removeStream (L201-205): synchronized 方法,
        // 移除后 notifyAll, 唤醒可能阻塞在连接级窗口更新上的线程
        synchronized(muLock) {
            let stream = streamMap.remove(streamId)
            muLock.notifyAll()
            return stream
        }
    }

    func writeHeaders(streamId: UInt32, outFinished: Bool, alternating: ArrayList<HeaderField>) {
        writer.headers(outFinished, streamId, alternating)
    }

    /**
     * The Function is writeData
     *
     * Write Data frame
     * Writes are subject to the write window of the stream and the connection. Until there is a
     * window sufficient to send
     *
     * @param streamId of UInt32
     * @param outFinished of Bool
     * @param buffer of ByteBuffer
     * @param length of Int64
     * @since 0.34.3
     */
    public func writeData(streamId: UInt32, outFinished: Bool, buffer: ByteBuffer, length: Int64) {
        var byteCount = length
        if (byteCount == 0) {
            // Empty data frames are not flow-controlled.
            writer.data(outFinished, streamId, buffer, 0)
            return
        }

        while (byteCount > 0) {
            var toWrite: Int64
            synchronized(muLock) {
                while (bytesLeftInWriteWindow <= 0) {
                    if (!streamMap.contains(streamId)) {
                        throw HttpException("stream closed")
                    }
                    muLock.wait()
                }

                toWrite = min(byteCount, bytesLeftInWriteWindow)
                toWrite = min(toWrite, writer.maxDataLength())
                bytesLeftInWriteWindow -= toWrite
            }
            byteCount -= toWrite
            writer.data(outFinished && byteCount == 0, streamId, buffer, toWrite)
        }
    }

    func headers(inFinished: Bool, streamId: UInt32, _: Int64, headerBlock: Array<HeaderField>) {
        // 对标 OkHttp ReaderRunnable.headers (L701-748): 锁内只查表,
        // "We don't want to hold a lock when we call receiveHeaders()"
        let stream: Option<H2Stream>
        synchronized(muLock) {
            stream = streamMap.get(streamId)
        }
        match (stream) {
            case Some(s) => s.receiveHeaders(toHeaders(headerBlock), inFinished)
            case None => ()
        }
    }

    public func setSettings(settings: Settings) {
        // 对标 OkHttp setSettings (L541-551): writer 外层锁, connection 内层锁,
        // 写帧在 writer 锁内、连接锁外, 与 newStream/shutdown 保持全局锁序 writer → connection
        synchronized(writer.mutex) {
            synchronized(muLock) {
                if (shutdown) {
                    throw ConnectionShutdownException("connection shutdown")
                }
                httpSettings.merge(settings)
            }
            writer.settings(settings)
        }
    }

    func data(inFinished: Bool, streamId: UInt32, source: OkBuffer, length: Int64) {
        // 对标 OkHttp ReaderRunnable.data (L682-699): getStream 为 synchronized 方法,
        // 持连接锁查表; 未知流发 RST_STREAM 并补连接级流控后丢弃数据
        let dataStream: Option<H2Stream>
        synchronized(muLock) {
            dataStream = streamMap.get(streamId)
        }
        match (dataStream) {
            case Some(ds) =>
                ds.receiveData(source, length)
                if (inFinished) {
                    ds.receiveHeaders(Header(), true)
                }
            case None =>
                writeSynResetLater(streamId, ErrorCode.PROTOCOL_ERROR)
                updateConnectionFlowControl(length)
                source.skipBuffer(length)
        }
    }

    func toHeaders(headerBlock: Array<HeaderField>): Header {
        let header: Header = Header()
        for (i in 0..headerBlock.size) {
            header.add(headerBlock[i].name, headerBlock[i].value.trim())
        }
        return header
    }

    func writeSynReset(streamId: UInt32, statusCode: ErrorCode) {
        writer.rstStream(streamId, statusCode)
    }

    func writeSynResetLater(streamId: UInt32, statusCode: ErrorCode) {
        spawn {
            try {
                writer.rstStream(streamId, statusCode)
            } catch (e: HttpException | SocketException | SocketTimeoutException) {
                // 对标 OkHttp: catch (IOException e) → failConnection(e); 仓颉中
                // SocketTimeoutException 与 SocketException 无继承关系, 需一并捕获
                close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }
    }

    func updateConnectionFlowControl(read: Int64) {
        // 对标 OkHttp: synchronized void updateConnectionFlowControl(long) (L211-217)
        synchronized(muLock) {
            unacknowledgedBytesRead += read

            if (unacknowledgedBytesRead >= httpSettings.getInitialWindowSize() / 2) {
                writeWindowUpdateLater(0, unacknowledgedBytesRead)
                unacknowledgedBytesRead = 0
            }
        }
    }

    func writeWindowUpdateLater(streamId: UInt32, unacknowledgedBytesRead: Int64) {
        spawn {
            try {
                writer.windowUpdate(streamId, unacknowledgedBytesRead)
            } catch (e: HttpException | SocketException | SocketTimeoutException) {
                // 对标 OkHttp: catch (IOException e) → failConnection(e); 仓颉中
                // SocketTimeoutException 与 SocketException 无继承关系, 需一并捕获
                close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }
    }

    public func isHealthy() {
        // 对标 OkHttp: public synchronized boolean isHealthy (L553-560),
        // shutdown 标志与 ping 计数器均由连接锁保护;
        // "A degraded pong is overdue": nowNs >= degradedPongDeadlineNs 才不健康
        synchronized(muLock) {
            if (shutdown) {
                return false
            }

            if (degradedPongsReceived < degradedPingsSent && DateTime.now().toUnixTimeStamp().toMilliseconds() >=
                degradedPongDeadline) {
                return false
            }

            return true
        }
    }

    /**
     * The Function is shutdownConn
     *
     * @param statusCode of ErrorCode
     * @since 0.34.3
     */
    public func shutdownConn(statusCode: ErrorCode) {
        // 对标 OkHttp Http2Connection.shutdown (L447-461):
        // synchronized (writer) { synchronized (this) { 标志置位 } writer.goAway(...) }
        // 客户端连接 lastGoodStreamId 恒为 0, 故 goAway 首参保持 0
        synchronized(writer.mutex) {
            synchronized(muLock) {
                if (shutdown) {
                    return
                }
                shutdown = true
            }
            writer.goAway(0, statusCode, Array<Byte>(1, repeat: 0))
        }
    }

    func windowUpdate(streamId: UInt32, windowSizeIncrement: Int64) {
        if (streamId == 0) {
            synchronized(muLock) {
                bytesLeftInWriteWindow += windowSizeIncrement
                muLock.notifyAll()
            }
        } else {
            // 对标 OkHttp ReaderRunnable.windowUpdate (L861-868): getStream 为
            // synchronized 方法, 持连接锁查表判空后再持流锁更新窗口
            let stream: Option<H2Stream>
            synchronized(muLock) {
                stream = streamMap.get(streamId)
            }
            match (stream) {
                case Some(s) =>
                    synchronized(s.mutex) {
                        s.addBytesToWriteWindow(windowSizeIncrement)
                    }
                case None => ()
            }
        }
    }

    func goAway(lastGoodStreamId: Int64, _: ErrorCode) {
        // 对标 OkHttp ReaderRunnable.goAway (L835-853):
        // "Copy the streams first. We don't want to hold a lock when we call receiveRstStream()."
        // 锁内只做快照并置位, receiveRstStream/removeStream 移到锁外
        let streamsCopy = ArrayList<H2Stream>()
        synchronized(muLock) {
            shutdown = true
            let arr = streamMap |> collectArray
            for (item in arr) {
                streamsCopy.add(item[1])
            }
        }
        for (stream in streamsCopy) {
            if (stream.id > UInt32(lastGoodStreamId)) {
                stream.receiveRstStream(REFUSED_STREAM)
                removeStream(stream.id)
            }
        }
    }

    func rstStream(streamId: UInt32, errorCode: ErrorCode) {
        match (removeStream(streamId)) {
            case Some(stream) => stream.receiveRstStream(errorCode)
            case None => ()
        }
    }

    func ping(reply: Bool, payload1: Int64, payload2: Int64) {
        if (reply) {
            // 对标 OkHttp ReaderRunnable.ping (L813-824): pong 计数器由连接锁保护
            synchronized(muLock) {
                if (payload1 == DEGRADED_PING) {
                    degradedPongsReceived++
                } else if (payload1 == INTERVAL_PING) {
                    intervalPongsReceived++
                } else if (payload1 == AWAIT_PING) {
                    awaitPongsReceived++
                    muLock.notifyAll()
                }
            }
        } else {
            // 对标 OkHttp (L825-831): Send a reply to a client ping if this is a
            // server and vice versa. 异步回 PONG(ack), 写失败由 writePing 内
            // failConnection 处理
            spawn {
                writePing(true, payload1, payload2)
            }
        }
    }

    func writePing(reply: Bool, payload1: Int64, payload2: Int64) {
        // 对标 OkHttp writePing (L409-415): catch (IOException e) → failConnection(e)
        try {
            writer.ping(reply, payload1, payload2)
        } catch (e: HttpException | SocketException | SocketTimeoutException) {
            close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
        }
    }

    func settings(settings: Settings) {
        spawn {
            applyAndAckSettings(settings)
        }
    }

    func applyAndAckSettings(settings: Settings) {
        // 对标 OkHttp ReaderRunnable.applyAndAckSettings (L773-807):
        // synchronized (writer) { synchronized (this) { 合并设置并快照待通知流 }
        // writer.applyAndAckSettings(peerSettings) },
        // 窗口增量更新在所有锁外逐流进行(仅当初始窗口变化时)
        var delta = 0
        let streamsToNotify = ArrayList<H2Stream>()
        synchronized(writer.mutex) {
            synchronized(muLock) {
                let priorWriteWindowSize = peerSettings.getInitialWindowSize()
                peerSettings.merge(settings)
                let peerInitialWindowSize = peerSettings.getInitialWindowSize()
                if (peerInitialWindowSize != -1 && peerInitialWindowSize != priorWriteWindowSize) {
                    delta = peerInitialWindowSize - priorWriteWindowSize
                    let arr = streamMap |> collectArray
                    for (item in arr) {
                        streamsToNotify.add(item[1])
                    }
                }
            }

            try {
                writer.applyAndAckSettings(peerSettings)
            } catch (e: HttpException | SocketException | SocketTimeoutException) {
                // 对标 Java: catch (IOException e) → failConnection(e)
                close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }
        if (streamsToNotify.size > 0) {
            for (stream in streamsToNotify) {
                synchronized(stream.mutex) {
                    stream.addBytesToWriteWindow(delta)
                }
            }
        }

        spawn {
            match (listener) {
                case Some(conn) => conn.onSettings(this)
                case None => ()
            }
        }
    }

    /**
     * The Function is newStream
     *
     * @param requestHeaders of ArrayList<HeaderField>
     * @param out of Bool
     *
     * @return Type of H2Stream
     * @since 0.34.3
     */
    public func newStream(request: Request): H2Stream {
        let h2Stream: H2Stream
        let outFinished: Bool = !has(request.getBody())
        // 对标 OkHttp newStream (L241-279): 请求头列表由调用方构建, 不在锁内
        let requestHeaders: ArrayList<HeaderField> = Http2ExchangeCodec.http2HeadersList(request)
        var flushHeaders: Bool = false
        var streamId: UInt32 = 0

        // 对标 OkHttp: synchronized (writer) { synchronized (this) { 分配并注册流 }
        // writer.headers(...) }, 保证全库单一锁序 writer → connection
        synchronized(writer.mutex) {
            synchronized(muLock) {
                if (Int32(nextStreamID) > Int32.Max / 2) {
                    shutdownConn(REFUSED_STREAM)
                }
                if (shutdown) {
                    throw ConnectionShutdownException("connection shutdown")
                }
                streamId = nextStreamID
                nextStreamID += 2
                h2Stream = H2Stream(streamId, this, outFinished)
                h2Stream.start()
                flushHeaders = outFinished || bytesLeftInWriteWindow == 0 || h2Stream.bytesLeftInWriteWindow == 0
                if (h2Stream.isOpen()) {
                    streamMap.add(streamId, h2Stream)
                }
            }
            writer.headers(outFinished, streamId, requestHeaders)
        }
        if (flushHeaders) {
            writer.flush()
        }
        return h2Stream
    }

    /**
     * The Function is getMaxConcurrentStreams
     *
     * @since 0.34.3
     */
    public func getMaxConcurrentStreams() {
        // 对标 OkHttp: public synchronized int maxConcurrentStreams() (L207-209),
        // 默认值 Integer.MAX_VALUE ≙ 仓颉 Int64.Max(服务端未声明时并发流数不限)
        synchronized(muLock) {
            return peerSettings.getMaxConcurrentStreams(Int64.Max)
        }
    }

    /**
     * Flush the writer
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func flush(): Unit {
        writer.flush()
    }
}
