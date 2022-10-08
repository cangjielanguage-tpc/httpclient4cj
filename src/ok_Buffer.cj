/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkBuffer class.
 */
package okhttp

from std import io.*


public class OkBuffer <: Source {
    private var source: InputStream
    private var closed: Bool = false
    private var buffer: ByteArrayStream = ByteArrayStream()
    public init (inputStream: InputStream) {
        this.source = inputStream
    }

    private func read(bytes: Array<Byte>): Int64 {
        let read = source.read(bytes)
        if(read != -1) {
            if(read == bytes.size) {
                buffer.write(bytes)
            } else {
                buffer.write(bytes.slice(0, read))
            }
        }
        return read
    }

    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (buffer.length == 0) {
           let arr = Array<Byte>(4096, item: 0)
           let read  =  read(arr)
           if( read == -1) {
               return -1
           }
        }
        let arr = Array<Byte>(min(byteCount, buffer.length), item: 0)
        let read = buffer.read(arr)
        bytes.write(arr)
        return read
    }

    func skipBuffer(limit: Int64): Unit {
       let bytes = Array<Byte>(limit, item: 0)
    }

    func skipSource(limit: Int64): Unit {
       let bytes = Array<Byte>(limit, item: 0)
    }

    public func checkOffsetAndCount(size: Int64, offset: Int64, byteCount: Int64): Unit {
        if(offset > size || size -offset < byteCount || size < 0 || byteCount < 0) {
            throw IllegalArgumentException("from=${offset} byteCount=${byteCount}")
        }
    }

    public func indexOf(b: Byte, start: Int64, end: Int64): Int64 {
        if (start >= 0 && end >= start) {
           var offSet = start
           if (end < buffer.length) {
               for(i in offSet..end) {
                   if (buffer.bytes()[i] == b) {
                       return i
                   }

               }
           } else {
              while(offSet < end) {
                  for(i in offSet..buffer.length) {
                     if (buffer.bytes()[i] == b) {
                       return i
                     }

                 }
                 read(Array<Byte>(4096, item: 0))
              }
           }
           return -1
        } else {
             throw IllegalArgumentException("from=${start} to=${end}")
        }
    }

    public func readUtf8LineStrict(): String {
        return readUtf8LineStrict(Int64.Max)
    }

    public func readUtf8LineStrict(limit: Int64): String {
        if(limit < 0) {
            throw  IllegalArgumentException("limit < 0: ${limit}")
        }
        let indexLF = indexOf(0xAu8, 0, limit)
        let indexCR = indexOf(0xDu8, 0, indexLF)
        if (indexCR != -1 && indexCR + 1 == indexLF) {
            if(indexCR == 0) {
                skipBuffer(2)
                return ""
            }
            let arr = Array<Byte>(indexCR, item: 0)
            buffer.read(arr)
            let line = String.fromUtf8(arr)
            skipBuffer(2)
            return line
        }
        throw IllegalArgumentException("can't find CRLF line")
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        closed = true
    }

    public func isClosed(): Bool {
        return closed
    }
}