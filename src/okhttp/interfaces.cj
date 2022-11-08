/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the all interfaces.
 */
package okhttp



public interface Sink {
    func write(bytes: Array<Byte>): Unit
    func flush(): Unit
    func close(): Unit
}

public interface Source <: Resource {
    func read(bytes: ByteArrayStream, byteCount: Int64): Int64
    func close(): Unit
    func isClosed(): Bool
}


/**
 * The interface is ExchangeCodec
 * @author luoyukai4
 * @since 0.29.3
 */
public interface ExchangeCodec {

    func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder>

    func reportedContentLength(response: Response): Int64

    func openResponseBodySource(response: Response): Source

    func getConnection(): Connection

    func cancel(): Unit

    func createRequestBody(request: Request): Sink

    func writeRequestHeaders(request: Request): Unit

    func flushRequest(): Unit

    func finishRequest(): Unit
}
