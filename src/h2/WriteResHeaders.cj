/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file handle the response header class.
 */

package h2

/* It is a request to write a header file and 0+ consecutive frames from the server handler for the HTTP response header or tail file. */
public open class H2WriteResHeaders {

    private let EMPTY_HEADER: Header = Header()
    private let EMPTY_ARRAYlIST: ArrayList<String> = ArrayList<String>()

    public var streamID: UInt32 = 0
    /* 0 means no ": status" line */
    protected var httpResCode: Int64 = 0
    protected var header: Header = Header()
    /* If not nil, which keys of H are written. Zero means all. */
    protected var trailers: ArrayList<String> = ArrayList<String>()
    protected var endStream: Bool = false

    protected var date: String = ""
    protected var contentType: String = ""
    protected var contentLength: String = ""

    public init(streamID!: UInt32 = 0, httpResCode!: Int64 = 0, header!: Header = Header(),
                trailers!: ArrayList<String> = ArrayList<String>(), endStream!: Bool = false,
                date!: String = "", contentType!: String = "", contentLength!: String = "") {
        this.streamID = streamID
        this.httpResCode = httpResCode
        this.header = header
        this.endStream = endStream
        this.contentType = contentType
        this.contentLength = contentLength
        this.date = date
    }

    /* The header of the response is processed and compressed to generate a header frame, which is stored in Conn's writeque */
    func writeFrameHeader(writeQue: SyncQueue<Http2Frame>, hpackEncode: Encoder): String {
        let arrHeaderField: ArrayList<HeaderField> = ArrayList<HeaderField>()
        if (this.httpResCode != 0) {
            encKV(":status", httpCodeString(this.httpResCode), arrHeaderField)
        }
        encodeHeaders(arrHeaderField)
        if (!this.contentType.isEmpty()) {
            encKV("content-type", this.contentType, arrHeaderField)
        }
        if (!this.contentLength.isEmpty()) {
            encKV("content-length", this.contentLength, arrHeaderField)
        }
        if (!this.date.isEmpty()) {
            encKV("date", this.date, arrHeaderField)
        }
        encKV(arrHeaderField)
        /* Compress the response header */
        let headerBlock: Array<UInt8> = hpackEncode.encode(arrHeaderField)
        // Conducive to GC
        arrHeaderField.clear()
        let isTrailersEmpty: Bool = this.trailers.isEmpty()
        if (headerBlock.size == 0 && isTrailersEmpty) {
            throw Http2Exception("unexpected empty hpack.")
        }
        return splitHeaderBlock(writeQue, headerBlock)
    }

    func encKV(name: String, value: String, arr: ArrayList<HeaderField>): Unit {
        let hf: HeaderField = HeaderField(name, value)
        arr.append(hf)
    }

    func encKV(arr: ArrayList<HeaderField>): Unit {
        let names: ArrayList<String> = ArrayList<String>()
        for ((name, values) in this.header) {
            names.append(name)
            var str = ""
            for (value in values) {
                if (str != "") {
                    str = "${str};${value}"
                } else {
                    str = value
                }
            }
            encKV(name, str, arr)
        }
        for (name in names) {
            this.header.remove(name)
        }
        // Conducive to GC
        names.clear()
    }

    func encodeHeaders(arr: ArrayList<HeaderField>): Unit {
        for (key in this.trailers) {
            let vv = this.header.getAll(key)
            let (k, ascii): (String, Bool) = lowerHeader(key)
            if (!ascii) {
                continue
            }
            if (!validWireHeaderFieldName(k)) {
                continue
            }
            let isTE: Bool = k.equals("transfer-encoding")
            for (v in vv) {
                if (!validHeaderFieldValue(v)) {
                    continue
                }
                if (isTE && !v.equals("trailers")) {
                    continue
                }
                encKV(k, v, arr)
            }
        }
    }

    func writeHeaderBlock(writeQue: SyncQueue<Http2Frame>, frag: Array<UInt8>, firstFrag: Bool, endHeaders: Bool): Unit {
        //EndHeaders: lastFrag
        if (firstFrag) {
            let headersFrame: Http2Frame = writeHeadersFrame(this.streamID, frag, this.endStream, endHeaders, 0)
            writeQue.put(headersFrame)
        } else {
            let continuationFrame: Http2Frame = writeContinuation(this.streamID, endHeaders, frag)
            writeQue.put(continuationFrame)
        }
    }

    func splitHeaderBlock(writeQue: SyncQueue<Http2Frame>, headerData: Array<UInt8>): String {
        let maxFrameSize = 16384//maxFrameSize: UInt32
        var first: Bool = true
        var headerBlock: Array<UInt8> = headerData

        while (headerBlock.size > 0) {
            var frag: Array<UInt8> = headerBlock
            if (frag.size > maxFrameSize) {
                frag = frag[0..maxFrameSize]
            }
            if (frag.size == headerBlock.size) {
                headerBlock = Array<UInt8>()
            } else {
                headerBlock = headerBlock[frag.size..headerBlock.size]
            }
            this.writeHeaderBlock(writeQue, frag, first, headerBlock.isEmpty())
            first = false
        }
        return ""
    }

}
