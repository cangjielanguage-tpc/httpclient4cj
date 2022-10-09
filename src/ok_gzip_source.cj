/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkGzipSource class.
 */
package okhttp

from std import io.*
from compress import zlib.*

public class OkGzipSource <: Source {
    private let base : ByteArrayStream =  ByteArrayStream()
    private let gzip: DecompressInputStream = DecompressInputStream(base, wrap: GzipFormat, bufLen: 4096)
    private let source: Source

    public init(source: Source) {
        this.source = source
    }

    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        let read = source.read(base, byteCount)
        if (read > 0) {
            let arr = Array<Byte>(read, item: 0)
            let read2 = gzip.read(arr)
            bytes.write(arr)
        }
        return read
    }

    public func close(): Unit {
        source.close
    }
    public func isClosed(): Bool{
        source.isClosed()
    }
}