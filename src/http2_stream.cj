/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file The file declares the H2Stream class.
 */

package httpclient4cj

/**
 * The class is H2Stream
 * @author luoyukai4
 * @since 0.34.3
 */
public class H2Stream {
    let id: UInt32
    var mutex: Monitor = Monitor()
    var cc: H2Connection

    let headersQueue: ArrayList<Header> = ArrayList<Header>()

    private var hasResponseHeaders = false
    var sink: FramingSink
    var source: FramingSource

    var errorCode: Option<ErrorCode> = Option<ErrorCode>.None
    var errorException: String = ""
    var unacknowledgedBytesRead = 0

    var bytesLeftInWriteWindow: Int64

    /**
     * The Function is init constructor
     *
     * @param ids of UInt32
     * @param cc of H2Connection
     * @param reqBody of ByteBuffer
     * @since 0.29.3
     */
    init(ids: UInt32, cc: H2Connection, outFinished: Bool) {
        this.id = ids
        this.cc = cc
        bytesLeftInWriteWindow = cc.peerSettings.getInitialWindowSize()
        sink = FramingSink(outFinished)
        source = FramingSource(cc.httpSettings.getInitialWindowSize())
    }

    /**
     * The Function is getId
     *
     * @since 0.34.3
     */
    public func getId() {
        return id
    }

    /**
     * Returns the reason why this stream was closed, or null if it closed normally or has not yet
     * been closed
     *
     * @return Type of Option<ErrorCode>
     * @since 0.34.3
     */
    public func getErrorCode(): Option<ErrorCode> {
        synchronized(mutex) {
            return errorCode
        }
    }

    /**
     * The Function is start
     *
     * @since 0.34.3
     */
    func start() {
        sink.http2Stream = this
        source.stream = this
    }

    /**
     * The Function is getSink
     *
     * @return Type of Sink
     * @since 0.34.3
     */
    public func getSink(): Sink {
        // 对标 OkHttp getSink (L247-254): synchronized 方法, 非本地发起的流在
        // 未发响应头前禁止取 sink。仓颉为纯客户端实现(流 id 恒为奇数, 均本地
        // 发起 ≙ Java isLocallyInitiated 恒 true), 该检查恒不触发, 保持结构对标
        synchronized(mutex) {
            if (!hasResponseHeaders && (id % 2) == 0) {
                throw IllegalStateException("reply before requesting the sink")
            }
        }
        return sink
    }

    /**
     * The Function is close
     *
     * Abnormally terminate this stream. This blocks until the RST_STREAM frame has been
     * transmitted.
     *
     * @param rstStatusCode of ErrorCode
     * @param errorException of String
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func close(rstStatusCode: ErrorCode, errorException: String): Unit {
        if (!closeInternal(rstStatusCode, errorException)) {
            return
        }
        cc.writeSynReset(id, rstStatusCode)
    }

    /**
     * Abnormally terminate this stream. This enqueues a RST_STREAM frame and returns
     * immediately.
     *
     *
     * @param rstStatusCode of ErrorCode
     *
     * @return Type of Unit
     * @since 0.34.3
     */
    public func closeLater(rstStatusCode: ErrorCode): Unit {
        if (!closeInternal(rstStatusCode, "")) {
            return
        }
        cc.writeSynResetLater(id, rstStatusCode)
    }

    func updateConnectionFlowControl(read: Int64) {
        cc.updateConnectionFlowControl(read)
    }

    /**
     * The Function is getConnection
     *
     * @since 0.34.3
     */
    public func getConnection(): H2Connection {
        return cc
    }

    /**
     * The Function is takeHeaders
     *
     * @since 0.34.3
     */
    public func takeHeaders(): Header {
        // 对标 OkHttp takeHeaders (L147-160): synchronized 方法, 出队与错误抛出均在锁内。
        // headersQueue 会被读线程(receiveHeaders, 持锁 add)并发访问,
        // 锁外 remove 与之构成 ArrayList 并发修改竞争; 错误路径也须在锁内
        // 基于 errorCode/errorException 构造异常, 消除锁外读取的撕裂窗口
        synchronized(mutex) {
            while (headersQueue.size == 0 && !has(errorCode)) {
                mutex.wait()
            }

            if (headersQueue.size != 0) {
                return headersQueue.remove(at: 0)
            }

            if (errorException == "") {
                throw StreamResetException(errorCode.getOrThrow())
            } else {
                throw HttpException("errorException")
            }
        }
    }

    func throwErrorException() {
        if (errorException == "") {
            throw StreamResetException(errorCode.getOrThrow())
        } else {
            throw HttpException("errorException")
        }
    }

    /**
     * The Function is enqueueTrailers
     *
     * @param trailers of Header
     * @since 0.34.3
     */
    public func enqueueTrailers(trailers: Header) {
        synchronized(mutex) {
            if (sink.finished) {
                throw IllegalStateException("already finished")
            }
            if (!has(trailers.iterator().next())) {
                throw IllegalArgumentException("trailers.size == 0")
            }
            this.sink.trailers = trailers
        }
    }

    private func closeInternal(rstStatusCode: ErrorCode, errorException: String): Bool {
        synchronized(mutex) {
            if (has(errorCode)) {
                return false
            }

            if (source.finished && sink.finished) {
                return false
            }
            this.errorCode = rstStatusCode
            this.errorException = errorException
            mutex.notifyAll()
        }

        cc.removeStream(id)
        return true
    }

    func checkOutNotClosed() {
        if (sink.closed) {
            throw HttpException("stream closed")
        } else if (sink.finished) {
            throw HttpException("stream finished")
        } else if (has(errorCode)) {
            throwErrorException()
        }
    }

    /**
     * The Function is getTrailers
     *
     * @return Type of Header
     * @since 0.34.3
     */
    public func getTrailers(): Header {
        // 对标 OkHttp trailers (L166-174): synchronized 方法,
        // errorCode/source 状态均由流锁保护
        synchronized(mutex) {
            if (has(errorCode)) {
                throwErrorException()
            }

            if (!source.finished || source.receiveBuffer.remainLength != 0 || source.readBuffer.remainLength != 0) {
                throw IllegalStateException("too early; can't read the trailers yet")
            }

            match (source.trailers) {
                case Some(v) => return v
                case None => return Header()
            }
        }
    }

    func receiveHeaders(headers: Header, inFinished: Bool) {
        var opened = false
        synchronized(mutex) {
            if (!hasResponseHeaders || !inFinished) {
                hasResponseHeaders = true
                headersQueue.add(headers)
            } else {
                source.trailers = headers
            }
            if (inFinished) {
                source.finished = true
            }
            opened = isOpen()
            mutex.notifyAll()
        }
        if (!opened) {
            cc.removeStream(id)
        }
    }

    func receiveRstStream(errorCode: ErrorCode) {
        // 对标 OkHttp receiveRstStream (L327-332): synchronized 方法,
        // 仅在首次设置 errorCode 时 notifyAll
        synchronized(mutex) {
            if (!has(this.errorCode)) {
                this.errorCode = errorCode
                mutex.notifyAll()
            }
        }
    }

    func cancelStreamIfNecessary() {
        var opened = false
        var cancel = false
        synchronized(mutex) {
            cancel = !source.finished && source.closed && (sink.finished || sink.closed)
            opened = isOpen()
        }

        if (cancel) {
            close(ErrorCode.CANCEL, "")
        } else if (!opened) {
            cc.removeStream(id)
        }
    }

    func addBytesToWriteWindow(delta: Int64) {
        // 对标 OkHttp addBytesToWriteWindow (L639-642): Java 方法本身无锁,
        // 由调用方(windowUpdate 处理器/applyAndAckSettings)持流锁调用并 notifyAll;
        // 仓颉此处锁外 notifyAll 属 Monitor 误用, 移入锁内
        synchronized(mutex) {
            bytesLeftInWriteWindow += delta
            if (delta > 0) {
                mutex.notifyAll()
            }
        }
    }

    /**
     * The Function is getSource
     *
     * @return Type of Source
     * @since 0.34.3
     */
    public func getSource(): Source {
        return source
    }

    /**
     * Returns true if this stream is open. A stream is open until either:
     * A SYN_RESET frame abnormally terminates the stream
     * Both input and output streams have transmitted all data and headers
     *
     * @since 0.34.3
     */
    public func isOpen() {
        // 对标 OkHttp isOpen (L120-130): synchronized 方法; Monitor 可重入,
        // receiveHeaders/cancelStreamIfNecessary 等锁内调用安全(与 Java 内在锁一致)
        synchronized(mutex) {
            if (has(errorCode)) {
                return false
            }

            if ((source.finished || source.closed) && (sink.finished || sink.closed) && hasResponseHeaders) {
                return false
            }

            return true
        }
    }

    func receiveData(source: OkBuffer, length: Int64) {
        this.source.receive(source, length)
    }
}
