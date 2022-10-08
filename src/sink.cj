/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Sink class.
 */
package okhttp

public interface Sink {
    func write(bytes: Array<Byte>): Unit
    func flush(): Unit
    func close(): Unit
}

class KnownLengthSink<: Sink {
    private var closed: Bool = false
    private let exchange: Http1ExchangeCodec

    init (exchange: Http1ExchangeCodec) {
        this.exchange = exchange
    }

    public func write(bytes: Array<Byte>): Unit {
        exchange.sink.write(bytes)

    }

    public func flush(): Unit {
        if(closed) {
            return
        }
        exchange.sink.flush()
    }

    public func close(): Unit {
        if(closed) {
            return
        }
        closed = true
        exchange.state = Http1ExchangeCodec.STATE_READ_RESPONSE_HEADERS
    }
}

class ChunkedSink<: Sink{
    private var closed: Bool = false
    private let exchange: Http1ExchangeCodec

    init (exchange: Http1ExchangeCodec) {
        this.exchange = exchange
    }

    public func write(bytes: Array<Byte>): Unit {
         if (closed) {
            throw IllegalStateException("closed");
         }
         let dataSize = bytes.size
         if (dataSize == 0) {
             return
         }
         var lengthHex = UInt64ToHexString(UInt64(dataSize))
         this.exchange.sink.write(lengthHex)
         this.exchange.sink.write(CRLF)
         this.exchange.sink.write(bytes)
         this.exchange.sink.write(CRLF)
    }

    public func flush(): Unit {
        if(closed) {
            return
        }
        exchange.sink.flush()
    }

    public func close(): Unit {
        if(closed) {
            return
        }
        closed = true
        this.exchange.sink.write(b"0\r\n\r\n")
        exchange.state = Http1ExchangeCodec.STATE_READ_RESPONSE_HEADERS
    }
}

class RequestBodySink<: Sink {
    private var completed: Bool = false
    private var contentLength: Int64
    private var bytesReceived: Int64 = 0
    private var closed: Bool = false
    private let exchange: Exchange
    private let sink: Sink

    init(sink: Sink, contentLength: Int64, exchange: Exchange) {
        this.sink = sink
        this.contentLength = contentLength
        this.exchange = exchange
    }

    public func write(bytes: Array<Byte>): Unit {
        let byteCount = bytes.size
        if (closed) {
            throw IllegalStateException("closed")
        }
        if (contentLength != -1 && bytesReceived + byteCount > contentLength) {
            throw ProtocolException("expected ${contentLength} bytes but received ${bytesReceived + byteCount}")
        }
        try {
            sink.write(bytes)
            this.bytesReceived += byteCount
        }catch (e: IOException) {
            complete(NetException(e.message))
            throw e
        }
    }
    public func flush(): Unit {
         try {
            sink.flush()
         } catch (e: IOException) {
            complete(NetException(e.message))
            throw e
         }
    }
    public func close(): Unit {
        if(closed) {
            return
        }
        closed = true
        if (contentLength != -1 && bytesReceived != contentLength) {
            throw ProtocolException("unexpected end of stream");
        }
        try {
           sink.close()
           complete(Option<NetException>.None)
        } catch (e: IOException) {
           complete(NetException(e.message))
           throw e
        }
    }

    private func complete(e: Option<NetException>): Unit {
        if (completed) {
            return
        }
        completed = true
        exchange.bodyComplete(false, true, e)
    }
}