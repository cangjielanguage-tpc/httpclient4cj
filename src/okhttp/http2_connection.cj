/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the xxxx class.
 */

package okhttp

let PREFACE: String = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"


/**
 * The class is H2Connection
 *
 *  A connection hosts streams which can send and receive
 *  data.
 *
 * @author luoyukai4
 * @since 0.34.3
 */
public class H2Connection {
    protected var socket: SocketClient
    protected var nextStreamID: UInt32 = 1
    protected var streams: HashMap<UInt32, H2Stream> = HashMap<UInt32, H2Stream>()
    var muLock: Monitor = Monitor()

    protected let hpackEncode: Encoder = Encoder.newEncoder()

    public prop let streamMap: HashMap<UInt32, H2Stream>  { get() {return streams }}

    static let OKHTTP_CLIENT_WINDOW_SIZE = 16 * 1024 * 1024
    var okHttpSettings: Settings = Settings()
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
    let listener: Connection
    var degradedPongDeadline: Time = Time.now()
    var unacknowledgedBytesRead = 0

    public init(socket: SocketClient, sink: BufferedOutputStream, source: OkBuffer, listener: Connection) {
        this.socket = socket
        this.listener = listener
        okHttpSettings.setting(Settings.INITIAL_WINDOW_SIZE, OKHTTP_CLIENT_WINDOW_SIZE)
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
     *  Sends any initial frames and starts reading frames from the remote peer. This should be called
     *  after init for all new connections.
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func start(): Unit {
        writer.connectionPreface()
        writer.settings(okHttpSettings)
        let windowSize = okHttpSettings.getInitialWindowSize()
        if (okHttpSettings.getInitialWindowSize() != Settings.DEFAULT_INITIAL_WINDOW_SIZE) {
            writer.windowUpdate(0, windowSize - Settings.DEFAULT_INITIAL_WINDOW_SIZE)
        }
        spawn {
            var connectionErrorCode: ErrorCode = INTERNAL_ERROR
            var streamErrorCode: ErrorCode = INTERNAL_ERROR
            var errorException: String = ""
            try {
                reader.readConnectionPreface(this)
                while (reader.nextFrame(false, this)) {}
                connectionErrorCode = ErrorCode.NO_ERROR
                streamErrorCode = ErrorCode.CANCEL
            } catch (e: IOException) {
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
        synchronized (muLock) {
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
        try {
            shutdownConn(connectionCode)
        } catch ( ignored: Exception) {

        }

        synchronized (muLock) {
            streamMap.removeIf({
                id: UInt32, stream: H2Stream =>
                    stream.close(streamCode, cause)
                    return true
            })
        }

        writer.close()

        try {
            socket.close()
        } catch ( ignored: Exception) {

        }
    }

    func removeStream(streamId: UInt32): Option<H2Stream> {
        let stream = streamMap.remove(streamId)
        muLock.lock()
        muLock.notifyAll()
        muLock.unlock()
        return stream
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
     * @param buffer of ByteArrayStream
     * @param length of Int64
     * @since 0.34.3
     */
    public func writeData(streamId: UInt32, outFinished: Bool, buffer: ByteArrayStream, length: Int64) {
        var byteCount = length
        if (byteCount == 0) {
             // Empty data frames are not flow-controlled.
             writer.data(outFinished, streamId, buffer, 0)
             return
        }

        while (byteCount > 0) {
            var toWrite: Int64
            synchronized (muLock) {
                while (bytesLeftInWriteWindow <= 0) {
                   if (!streamMap.contains(streamId)) {
                       throw IOException("stream closed")
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

    func headers(inFinished: Bool, streamId: UInt32, associatedStreamId: Int64, headerBlock: Array<HeaderField>) {
        synchronized(muLock) {
            let stream = streamMap[streamId]
            stream.receiveHeaders(toHeaders(headerBlock), inFinished)
        }
    }

    func data(inFinished: Bool, streamId: UInt32, source: OkBuffer, length: Int64) {
        let dataStream = streamMap[streamId]
        dataStream.receiveData(source, length)
        if (inFinished) {
            dataStream.receiveHeaders(Header(), true)
        }
    }

    func toHeaders(headerBlock: Array<HeaderField>): Header {
        let header:Header = Header()
        for (headerField in  headerBlock) {
            header.add(headerField.name, headerField.value.trim())
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
            } catch (e: IOException | SocketException) {
                close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }
    }

    func updateConnectionFlowControl(read: Int64) {
        unacknowledgedBytesRead += read

        if (unacknowledgedBytesRead >= okHttpSettings.getInitialWindowSize() / 2) {
            writeWindowUpdateLater(0, unacknowledgedBytesRead)
            unacknowledgedBytesRead = 0
        }
    }

    func writeWindowUpdateLater(streamId: UInt32, unacknowledgedBytesRead: Int64) {
        spawn {
            try {
                writer.windowUpdate(streamId, unacknowledgedBytesRead)
            } catch (e: IOException | SocketException) {
                 close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }
    }

    public func isHealthy(time: Time) {
        if (shutdown) {
            return false
        }

        if (degradedPongsReceived < degradedPingsSent && time <= degradedPongDeadline) {
            return false
        }

        return true
    }

    /**
     * The Function is shutdownConn
     *
     * @param statusCode of ErrorCode
     * @since 0.34.3
     */
    public func shutdownConn(statusCode: ErrorCode) {
        synchronized(writer.mutex) {
            synchronized (muLock) {
                if (shutdown) {
                    return
                }
            }
            shutdown = true
        }
        writer.goAway(0, statusCode, Array<Byte>(1, item: 0))
    }

    func windowUpdate(streamId: UInt32, windowSizeIncrement: Int64) {
        if (streamId == 0) {
            synchronized (muLock) {
                bytesLeftInWriteWindow += windowSizeIncrement
                muLock.notifyAll();
            }
        } else {
            let stream = streamMap[streamId]

            synchronized (stream.mutex) {
                 stream.addBytesToWriteWindow(windowSizeIncrement)
            }
       }
    }

    func goAway(lastGoodStreamId: Int64, errorCode: ErrorCode) {
        synchronized (muLock) {
            shutdown = true
            streamMap.removeIf({
                id: UInt32, stream: H2Stream =>
                    if (stream.id > UInt32(lastGoodStreamId)) {
                        stream.receiveRstStream(REFUSED_STREAM)
                        removeStream(stream.id)
                        muLock.notifyAll()
                        return true
                    } else {
                        return false
                    }
            })
        }
    }

    public func rstStream(streamId: UInt32, errorCode: ErrorCode) {
        match (removeStream(streamId)) {
            case Some(stream)  =>  stream.receiveRstStream(errorCode)
            case None => ()
        }
    }

    public func ping(reply: Bool, payload1: Int64, payload2: Int64) {
        if (reply) {
            if (payload1 == INTERVAL_PING) {
                intervalPongsReceived++;
            } else if (payload1 == DEGRADED_PING) {
                degradedPongsReceived++;
            } else if (payload1 == AWAIT_PING) {
                awaitPongsReceived++;
                muLock.notifyAll()
            }
        }
    }

    func writePing(reply: Bool, payload1: Int64, payload2: Int64) {
        writer.ping(reply, payload1, payload2)
    }

    func settings(settings: Settings) {
        spawn {
            applyAndAckSettings(settings)
        }
    }

    func applyAndAckSettings(settings: Settings) {
        var delta = 0
        synchronized(writer.mutex) {
            synchronized(muLock) {
                let priorWriteWindowSize = peerSettings.getInitialWindowSize()
                peerSettings.merge(settings)
                let peerInitialWindowSize = peerSettings.getInitialWindowSize()
                if (peerInitialWindowSize != -1 && peerInitialWindowSize != priorWriteWindowSize) {
                    delta = peerInitialWindowSize - priorWriteWindowSize
                }
            }

            try {
                writer.applyAndAckSettings(peerSettings)
            } catch (e: IOException | SocketException) {
                close(ErrorCode.PROTOCOL_ERROR, ErrorCode.PROTOCOL_ERROR, e.message)
            }
        }

        for ((k,v) in streamMap) {
            synchronized(v.mutex) {
                v.addBytesToWriteWindow(delta)
            }

        }

        spawn {
            listener.onSettings(this)
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
    public func newStream(requestHeaders: ArrayList<HeaderField>, out: Bool): H2Stream {
        let h2Stream: H2Stream
        let outFinished: Bool = !out
        let inFinished: Bool = false
        var flushHeaders: Bool = false
        var streamId: UInt32 = 0
        synchronized (writer.mutex) {
            synchronized(muLock) {
                if (Int32(nextStreamID) > Int32.Max / 2) {
                    shutdownConn(REFUSED_STREAM)
                }
                if (shutdown) {
                   throw IOException("connection shutdown")
                }
                streamId = nextStreamID
                nextStreamID += 2
                flushHeaders = !out || bytesLeftInWriteWindow == 0
                h2Stream  = H2Stream(streamId, this, outFinished, inFinished)
                h2Stream.start()
                if (h2Stream.isOpen()) {
                    streamMap.put(streamId, h2Stream)
                }

                writer.headers(outFinished, streamId, requestHeaders)

            }
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
        return peerSettings.getMaxConcurrentStreams(100)
    }

    /**
     *  Flush the writer
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func flush(): Unit {
        writer.flush()
    }
}