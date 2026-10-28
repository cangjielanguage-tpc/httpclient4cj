/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the OkBuffer class.
 */

package httpclient4cj

public class OkBuffer <: Source {
    private var source: InputStream
    private var closed: Bool = false
    private var buffer: ByteBuffer = ByteBuffer()
    // 语义不变的缓冲复用：仅替换临时数组分配
    private var readBuf: Array<Byte> = Array<Byte>(4096, repeat: 0)
    private var scratch: Array<Byte> = Array<Byte>(1024, repeat: 0)
    public init(inputStream: InputStream) {
        this.source = inputStream
    }

    private func ensureScratch(size: Int64): Array<Byte> {
        if (scratch.size < size) {
            scratch = Array<Byte>(size, repeat: 0)
        }
        return scratch
    }

    private func read(bytes: Array<Byte>): Int64 {
        var read = 0

        try {
            read = source.read(bytes)
        } catch (e: SocketException) {
            return -1
        }

        if (read == 0) {
            throw EOFException()
        } else if (read != -1) {
            // 缓冲排空时先 clear 再写入，回收已读空间，避免容量随累计接收字节数无限增长
            if (buffer.remainLength == 0) {
                buffer.clear()
            }
            buffer.write(bytes[..read])
        }

        return read
    }

    func exhausted(): Bool {
        return buffer.remainLength == 0
    }

    public func readByte(): Byte {
        let arr = Array<Byte>(1, repeat: 0)

        if (buffer.remainLength > 0) {
            buffer.read(arr)
        } else {
            read(readBuf)
            buffer.read(arr)
        }
        return arr[0]
    }

    public func read(bytes: ByteBuffer, byteCount: Int64): Int64 {
        if (closed) {
            throw IllegalStateException("closed")
        }

        if (buffer.remainLength == 0) {
            let read = read(readBuf)
            if (read == -1) {
                return -1
            }
        }

        let arr = Array<Byte>(min(byteCount, buffer.remainLength), repeat: 0)
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

        if (buffer.remainLength >= limit) {
            buffer.seek(SeekPosition.Current(limit))
            return
        }

        let bytes = Array<Byte>(limit, repeat: 0)
        read(readBuf)
        buffer.read(bytes)
    }

    /**
     * 快路径：跳过已知长度的 body（close 丢弃），已缓冲部分直接 seek，避免分配中转数组。
     */
    func skipBytes(limit: Int64): Unit {
        if (limit < 0) {
            throw IllegalArgumentException("limit = ${limit} < 0")
        }
        var remaining = limit
        while (remaining > 0) {
            if (buffer.remainLength == 0) {
                if (read(readBuf) == -1) {
                    throw ProtocolException("unexpected end of stream")
                }
            }
            let n = min(remaining, buffer.remainLength)
            buffer.seek(SeekPosition.Current(n))
            remaining -= n
        }
    }

    public func indexOf(b: Byte, start: Int64, end: Int64): Int64 {
        if (start >= 0 && end >= start) {
            var offSet = start
            if (end < buffer.remainLength) {
                let bytes = buffer.bytes()
                var i = offSet
                while (i < end) {
                    if (bytes[i] == b) {
                        return i
                    }
                    i++
                }
            } else {
                while (offSet < end) {
                    let remaining = buffer.remainLength
                    if (offSet < remaining) {
                        let bytes = buffer.bytes()
                        var i = offSet
                        while (i < remaining) {
                            if (i > end) {
                                return -1
                            }
                            if (bytes[i] == b) {
                                return i
                            }
                            i++
                        }
                        offSet = remaining
                    }

                    if (read(readBuf) == -1) {
                        return -1
                    }
                }
            }

            return -1
        } else {
            throw IllegalArgumentException("from=${start} to=${end}")
        }
    }

    /**
     * 快路径：一次性读取整个响应头块，块内行以 CRLF 分隔，不含结束空行。
     * 返回的字符串只做一次分配，避免逐行构造 String 与 StringBuilder 追加。
     */
    func readHeaderBlockStrict(limit: Int64): (String, Int64) {
        if (limit < 0) {
            throw IllegalArgumentException("limit < 0: ${limit}")
        }
        var scanned = 0
        while (true) {
            let avail = buffer.remainLength
            // 未找到终止符时限制缓冲增长；+readBuf.size 允许同一次 recv 带入的 body 数据
            if (avail > 2 * limit + readBuf.size + 16) {
                throw EOFException(##"can't find CRLF line"##)
            }
            let bytes = buffer.bytes()
            var i = scanned
            while (i + 1 < avail) {
                if (bytes[i] == 0x0Du8 && bytes[i + 1] == 0x0Au8) {
                    if (i == 0 || (i >= 2 && bytes[i - 2] == 0x0Du8 && bytes[i - 1] == 0x0Au8)) {
                        var crlfCount = 0
                        var j = 0
                        while (j + 1 < i) {
                            if (bytes[j] == 0x0Du8 && bytes[j + 1] == 0x0Au8) {
                                crlfCount++
                                j += 2
                            } else {
                                j++
                            }
                        }
                        let contentSize = i - crlfCount * 2
                        if (contentSize > limit) {
                            throw EOFException(##"can't find CRLF line"##)
                        }
                        // buffer.bytes() 是零拷贝视图；先构串再一次性 seek 掉整块 + 结束空行
                        let block = if (i > 0) { bytes[0..i] } else { Array<Byte>(0, repeat: 0) }
                        let text = String.fromUtf8(block)
                        buffer.seek(SeekPosition.Current(i + 2))
                        return (text, contentSize)
                    }
                }
                i++
            }
            scanned = if (avail > 3) { avail - 3 } else { 0 }
            if (read(readBuf) == -1) {
                throw EOFException(##"can't find CRLF line"##)
            }
        }
        return ("", 0)
    }

    public func readUtf8LineStrict(): String {
        return readUtf8LineStrict(Int64.Max)
    }

    public func readUtf8LineStrict(limit: Int64): String {
        if (limit < 0) {
            throw IllegalArgumentException("limit < 0: ${limit}")
        }
        var index = 0
        while (true) {
            let indexLF = indexOf(0xAu8, index, limit)

            if (indexLF == -1) {
                break
            }

            if (indexLF != 0) {
                let indexCR = indexOf(0xDu8, indexLF - 1, indexLF)
                if (indexCR + 1 == indexLF) {
                    if (indexCR == 0) {
                        skipBuffer(2)

                        return ""
                    }

                    let sbuf = ensureScratch(indexCR)
                    let slice = sbuf[0..indexCR]
                    buffer.read(slice)
                    let line = String.fromUtf8(slice)
                    skipBuffer(2)

                    return line
                }
            }

            index = indexLF + 1
        }

        throw EOFException(##"can't find CRLF line"##)
    }

    public func readUtf8Line(): String {
        return readUtf8Line(Int64.Max)
    }

    public func readUtf8Line(limit: Int64): String {
        if (limit < 0) {
            throw IllegalArgumentException("limit < 0: ${limit}")
        }

        let indexLF = indexOf(0xAu8, 0, limit)
        if (indexLF == -1) {
            throw EOFException(##"can't find '\n' line"##)
        }

        if (indexLF == 0) {
            skipBuffer(1)
            return ""
        }

        let sbuf = ensureScratch(indexLF)
        let slice = sbuf[0..indexLF]
        buffer.read(slice)
        let line = String.fromUtf8(slice)
        skipBuffer(1)
        return line
    }

    public func close(): Unit {
        if (closed) {
            return
        }

        closed = true
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
