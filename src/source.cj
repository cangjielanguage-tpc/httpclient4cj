/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Sink class.
 */
package okhttp
from std import math.*

public interface Source <: Resource {
    func read(bytes: ByteArrayStream, byteCount: Int64): Int64
    func close(): Unit
    func isClosed(): Bool
}

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
        if(closed) {return}
        if (bytesRemaining != 0){
            exchangeCode.source.skipSource(bytesRemaining)
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
        if(closed) {return}
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
        let chunkedLength: String = exchangeCode.source.readUtf8LineStrict().trim()
        match (HexStringToUInt64(chunkedLength.toUtf8Array())) {
            case Some(c) =>
                if(c == 0) {
                    hasMoreChunks = false
                    exchangeCode.trailers = exchangeCode.readHeaders()
                    exchangeCode.responseBodyComplete()
                }
                bytesRemainingInChunk = Int64(c)
            case None => throw ProtocolException("expected chunked size failed")
        }
    }

    public func close(): Unit {
        if(closed) {return}
        if (hasMoreChunks) {
           //TODO skipALl
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

   init(source: Source, exchange: Exchange, contentLength: Int64){
        this.source = source
        this.exchange = exchange
        this.contentLength = contentLength
        if (contentLength == 0) {
            complete(Option<NetException>.None)
        }
   }

   public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }
        try{
            let read = source.read(bytes, byteCount)
            if (read == -1) {
                complete(Option<NetException>.None)
                return -1
            }
            let newBytesReceived = bytesReceived + read
            if(contentLength != -1 && newBytesReceived > contentLength) {
                throw ProtocolException("expected ${contentLength} bytes but received ${newBytesReceived}")
            }
            bytesReceived = newBytesReceived
            if(newBytesReceived == contentLength) {
                complete(Option<NetException>.None)
            }
            return read
        } catch (e: IOException) {
            complete(NetException(e.message))
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
           complete(Option<NetException>.None);
       } catch (e: IOException) {
           complete(NetException(e.message))
           throw e
       }
   }
   public func isClosed(): Bool {
       return closed
   }

   private func complete(e: Option<NetException>): Unit {
        if (completed) {
            return
        }
        completed = true
        exchange.bodyComplete(true, false, e)
   }
}