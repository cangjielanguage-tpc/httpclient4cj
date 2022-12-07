/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the OkBuffer class.
 */
package okhttp


public class OkBuffer <: Source {
    private var source: InputStream
    private var closed: Bool = false
    private var buffer: ByteArrayStream = ByteArrayStream()
    public init (inputStream: InputStream) {
        this.source = inputStream
    }

    private func read(bytes: Array<Byte>): Int64 {
        let read = source.read(bytes)

        if (read <= 0) {
            throw HttpException("EOF")
        } else if (read != -1) {
            if (read == bytes.size) {
                buffer.write(bytes)
            } else {
                buffer.write(bytes.slice(0, read))
            }
        }

        return read
    }

    func exhausted(): Bool {
        return buffer.size == 0
    }

    public func readByte(): Byte {

        let arr = Array<Byte>(1, item: 0)

        if (buffer.length > 0) {
            buffer.read(arr)
        } else {
            let arr2 = Array<Byte>(4096, item: 0)
            read(arr2)
            buffer.read(arr)
        }
        return arr[0]
    }


    public func read(bytes: ByteArrayStream, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }

        if (buffer.length == 0) {
           let arr = Array<Byte>(4096, item: 0)
           let read = read(arr)
           if (read == -1) {
               return -1
           }
        }

        let arr = Array<Byte>(min(byteCount, buffer.length), item: 0)
        let read = buffer.read(arr)
        bytes.write(arr)
        return read
    }

    public func skipBuffer(limit: Int64): Unit {

       if (limit < 0) {
           throw IllegalArgumentException("limit = ${limit} < 0")
       } else if (limit == 0) {
           return
       }

       let bytes = Array<Byte>(limit, item: 0)
       if (buffer.length >= limit) {
           buffer.read(bytes)
       } else {
           let arr2 = Array<Byte>(4096, item: 0)
           read(arr2)
           buffer.read(bytes)
       }

    }

    public func indexOf(b: Byte, start: Int64, end: Int64): Int64 {
        if (start >= 0 && end >= start) {
           var offSet = start
           if (end < buffer.length) {
               for (i in offSet..end) {
                   if (buffer.bytes()[i] == b) {
                       return i
                   }
               }
           } else {
              while (offSet < end) {
                 for (i in offSet..buffer.length) {
                     if (buffer.bytes()[i] == b) {
                       return i
                     }
                 }
                 offSet = buffer.length
                 if (read(Array<Byte>(4096, item: 0)) == -1) {
                     return -1
                 }
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
        if (limit < 0) {
            throw  IllegalArgumentException("limit < 0: ${limit}")
        }
        var index = 0
        while (true) {
            let indexLF = indexOf(0xAu8, index, limit)
            if (indexLF == -1) {
                break
            }
            let indexCR = indexOf(0xDu8, indexLF - 1, indexLF)
            if (indexCR != -1 && indexCR + 1 == indexLF) {
                if (indexCR == 0) {
                    skipBuffer(2)
                    return ""
                }
                let arr = Array<Byte>(indexCR, item: 0)
                buffer.read(arr)
                let line = String.fromUtf8(arr)
                skipBuffer(2)
                return line
            }
            index = indexLF
        }
        throw IllegalArgumentException("can't find CRLF line")
    }

    public func close(): Unit {
        if (closed) {
            return
        }
        buffer.clear()
        match (source) {
            case r: Resource => r.close()
            case _ => ()
        }
    }

    public func isClosed(): Bool {
        return closed
    }
}