/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Sink class.
 */
package okhttp
from std import math.*

abstract class AbstractSource <: Source {
    protected var closed: Bool = false
    protected let exchangeCode: Http1ExchangeCodec

    init(exchange: Http1ExchangeCodec) {
        this.exchangeCode = exchange
    }

    open public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        return exchangeCode.source.read(bytes, byteCount)
    }

    open public func isClosed(): Bool {
        return closed
    }
}

class FixedLengthSource <: AbstractSource {
    private var bytesRemaining: Int64

    init(length: Int64, exchange: Http1ExchangeCodec) {
        super(exchange)
        this.bytesRemaining = length

        if (bytesRemaining == 0) {
            exchangeCode.responseBodyComplete()
        }
    }

    public func read(bytes: ByteArrayStream, count: Int64): Int64 {
        var byteCount = count

        if (closed) {
            throw IllegalStateException("closed")
        }

        if (bytesRemaining == 0) {
            return -1
        }

        if (byteCount > bytesRemaining) {
            byteCount = bytesRemaining
        }

        let read = super.read(bytes, byteCount)

        if (read == -1) {
            exchangeCode.getConnection().noExchanges()
            exchangeCode.responseBodyComplete()
            throw ProtocolException("unexpected end of stream")
        }

        bytesRemaining -= read

        if (bytesRemaining == 0) {
           exchangeCode.responseBodyComplete()
        }
        return read
    }

    public func close(): Unit {
        if (closed) {
            return
        }

        if (bytesRemaining != 0 && !disCard(this)) {
            exchangeCode.getConnection().noExchanges()
            exchangeCode.responseBodyComplete()
        }

        closed = true
    }
}

class UnknownLengthSource <: AbstractSource {
    private var inputExhausted: Bool = false

    init(exchange: Http1ExchangeCodec) {
        super(exchange)
    }

    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }

        if (inputExhausted) {
            return -1
        }

        let buffer = exchangeCode.source
        let read = buffer.read(bytes, byteCount)

        if (read == -1) {
            inputExhausted = true
            exchangeCode.responseBodyComplete()
        }

        return read
    }

    public func close(): Unit {
        if (closed) {
            return
        }

        if (!inputExhausted) {
           exchangeCode.responseBodyComplete()
        }

        closed = true
    }
}


class ChunkedSource <: Source {
    private let exchangeCode: Http1ExchangeCodec
    private static let NO_CHUNK_YET = -1
    private var closed: Bool = false
    private var hasMoreChunks: Bool = true
    private var url: URL
    private var bytesRemainingInChunk: Int64 = NO_CHUNK_YET

    init(url: URL, exchange: Http1ExchangeCodec) {
        this.url = url
        this.exchangeCode = exchange
    }

    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }

        if (!hasMoreChunks) {
            return -1
        }

        if (bytesRemainingInChunk == 0 || bytesRemainingInChunk == NO_CHUNK_YET) {
           readChunkSize()
           if (!hasMoreChunks) {
               return -1
           }
        }

        let buffer = exchangeCode.source
        let read = buffer.read(bytes, min(byteCount, bytesRemainingInChunk))

        if (read == -1) {
            exchangeCode.getConnection().noExchanges()
            exchangeCode.responseBodyComplete()
            throw ProtocolException("unexpected end of stream")
        }
        bytesRemainingInChunk -= read
        return read
    }

    private func readChunkSize() {
        let arr = ByteArrayStream()

        if (bytesRemainingInChunk != NO_CHUNK_YET) {
            exchangeCode.source.skipBuffer(2)
        }

        let chunkedLength: String = exchangeCode.source.readUtf8LineStrict().trim()

        if (chunkedLength.size != 0) {
            match (HexStringToUInt64(chunkedLength.toUtf8Array())) {
                case Some(c) =>
                    if (c == 0) {
                        hasMoreChunks = false
                        exchangeCode.trailers = exchangeCode.readHeaders()
                        receiveHeaders(exchangeCode.client.getCookieJar(), url, exchangeCode.trailers)
                        exchangeCode.responseBodyComplete()
                    }
                    bytesRemainingInChunk = Int64(c)
                case None => throw ProtocolException("expected chunked size failed")
            }
        }
    }

    public func close(): Unit {
        if (closed) {return}

        if (hasMoreChunks && !disCard(this)) {
           exchangeCode.getConnection().noExchanges()
           exchangeCode.responseBodyComplete()
        }

        closed = true
    }

    public func isClosed(): Bool {
        return closed
    }
}

class ResponseBodySource <:Source {
   private let contentLength: Int64
   private var bytesReceived: Int64 = 0
   private var completed: Bool = false
   private var closed: Bool = false
   private let exchange: Exchange
   private let source: Source

   init(source: Source, exchange: Exchange, contentLength: Int64) {
        this.source = source
        this.exchange = exchange
        this.contentLength = contentLength
        if (contentLength == 0) {
            complete(Option<HttpException>.None)
        }
   }

   public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }

        try{
            let read = source.read(bytes, byteCount)
            if (read == -1) {
                complete(Option<HttpException>.None)
                return -1
            }
            let newBytesReceived = bytesReceived + read
            if (contentLength != -1 && newBytesReceived > contentLength) {
                throw ProtocolException("expected ${contentLength} bytes but received ${newBytesReceived}")
            }
            bytesReceived = newBytesReceived
            if (newBytesReceived == contentLength) {
                complete(Option<HttpException>.None)
            }
            return read
        } catch (e: HttpException) {
            complete(HttpException(e.message))
            throw e
        }
   }
   public func close(): Unit {
       if (closed) {
           return
       }

       closed = true
       try {
           source.close()
           complete(Option<HttpException>.None)
       } catch (e: HttpException) {
           complete(HttpException(e.message))
           throw e
       }
   }
   public func isClosed(): Bool {
       return closed
   }

   private func complete(e: Option<HttpException>): Unit {
        if (completed) {
            return
        }

        completed = true
        exchange.bodyComplete(true, false, e)
   }
}


class FramingSource <: Source {
    var finished: Bool = false
    var trailers: Option<Header> = Option<Header>.None
    var stream: Option<H2Stream> = Option<H2Stream>.None
    var maxByteCount: Int64
    let readBuffer = ByteArrayStream()
    let receiveBuffer = ByteArrayStream()
    var closed = false

    public init(maxByteCount: Int64) {
         this.maxByteCount = maxByteCount
    }

    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        let h2Stream = stream.getOrThrow()

        if (byteCount < 0) {
            throw IllegalArgumentException("byteCount = ${byteCount} < 0")
        }

        while (true) {
            var readBytesDelivered = -1
            var errorExceptionToDeliver: Bool = false
            synchronized(h2Stream.mutex) {
                if (has(h2Stream.errorCode)) {
                    errorExceptionToDeliver = true
                }

                if (closed) {
                    throw HttpException("stream closed")
                } else if (readBuffer.length > 0) {
                   let arr = Array<Byte>(min(byteCount, readBuffer.length), item:0)
                   readBytesDelivered =  readBuffer.read(arr)
                   bytes.write(arr)
                   h2Stream.unacknowledgedBytesRead += readBytesDelivered
                   if (!errorExceptionToDeliver && h2Stream.unacknowledgedBytesRead >=
                         h2Stream.cc.okHttpSettings.getInitialWindowSize() / 2) {
                         h2Stream.cc.writeWindowUpdateLater(h2Stream.id, h2Stream.unacknowledgedBytesRead)
                         h2Stream.unacknowledgedBytesRead = 0
                   }
                } else if (!finished && !errorExceptionToDeliver) {
                    h2Stream.mutex.wait()
                    continue
                }
            }

            if (readBytesDelivered != -1) {
                h2Stream.updateConnectionFlowControl(readBytesDelivered)
                return readBytesDelivered
            }

            if (errorExceptionToDeliver) {
                if (h2Stream.errorException == "") {
                    throw StreamResetException(h2Stream.errorCode.getOrThrow())
                } else {
                    throw HttpException("errorException")
                }
            }
            return -1
        }
        return -1
    }

    func receive(source: OkBuffer, length: Int64) {
        var byteCount = length
        while(byteCount > 0) {
            var finished: Bool
            var flowControlError: Bool
            synchronized (stream.getOrThrow().mutex) {
                finished = this.finished
                flowControlError =  byteCount + readBuffer.length > maxByteCount
            }

            if (flowControlError) {
                source.skipBuffer(byteCount)
                stream.getOrThrow().closeLater(ErrorCode.FLOW_CONTROL_ERROR)
                return
            }

            if (finished) {
                source.skipBuffer(byteCount)
                return
            }

            let read = source.read(receiveBuffer, byteCount)

            if (read == -1) {
                throw HttpException("EOF")
            }

            byteCount -= read
            var bytesDiscarded = 0
            synchronized(stream.getOrThrow().mutex) {
                if (closed) {
                    bytesDiscarded = receiveBuffer.length
                    receiveBuffer.clear()
                } else {
                    let  wasEmpty = readBuffer.length == 0
                    readBuffer.write(receiveBuffer.readToEnd())
                    if (wasEmpty) {
                        let mu = stream.getOrThrow().mutex
                        mu.notifyAll()
                    }

                }

            }

            if (bytesDiscarded > 0) {
                stream.getOrThrow().updateConnectionFlowControl(bytesDiscarded);
            }
        }
    }

    public func close(): Unit {


    }
    public func isClosed(): Bool {
        return closed
    }
}
