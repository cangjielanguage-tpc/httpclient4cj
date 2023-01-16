/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the MultipartBody class.
 */
package okhttp

from std import random.*

/**
 * The class is MultipartBody
 * @author luoyukai4
 * @since 0.33.3
 */
public class MultipartBody <: RequestBody {
    public static let MIXED: MediaType = MediaType.get("multipart/mixed")
    public static let ALTERNATIVE: MediaType = MediaType.get("multipart/alternative")
    public static let DIGEST: MediaType = MediaType.get("multipart/digest")
    public static let PARALLEL: MediaType = MediaType.get("multipart/parallel")
    public static let FORM: MediaType = MediaType.get("multipart/form-data")

    private static let DASHDASH: Array<Byte> = b"--"
    private static let COLONSPACE: Array<Byte> = b": "

    private let boundary: String
    private let originalType: MediaType
    private let realType: MediaType
    private let parts: ArrayList<Part>
    private var contentLength: Int64 = -1

    init (boundary: String, originalType: MediaType, parts: ArrayList<Part>) {
        this.boundary = boundary
        this.originalType = originalType
        this.parts = parts
        this.realType = MediaType.get("${originalType}; boundary=${boundary}")
    }

    public func get(): InputStream {
        let arr = ByteArrayStream()
        writeOrCountBytes(arr, true)
        return arr
    }

    public func getContentLength(): Int64 {
        if (contentLength != -1) {
            return contentLength
        } else {
            contentLength = writeOrCountBytes(ByteArrayStream(), false)
            return contentLength
        }
    }

    public func getType(): MediaType {
        return originalType
    }

    public func getBoundary(): String {
        return boundary
    }

    public func getParts(): ArrayList<Part> {
        return parts
    }

    public func contentType(): Option<MediaType> {
        return realType

    }

    public func writeTo(sink: Sink): Unit {
       writeOrCountBytes(sink)
    }

    private func writeOrCountBytes(arr: ByteArrayStream, write: Bool): Int64 {
        var byteCount = 0

        for (p in 0..parts.size) {
            let part: Part = parts[p]
            let headers = part.headers
            let body = part.body
            arr.write(DASHDASH)
            arr.write(boundary.toUtf8Array())
            arr.write(CRLF)
            match (headers) {
                case Some(h) =>
                    for ((k,v) in h) {
                        for (e in v) {
                            arr.write(k.toUtf8Array())
                            arr.write(COLONSPACE)
                            arr.write(e.toUtf8Array())
                            arr.write(CRLF)
                        }
                    }
                case None => ()
            }

            let mediaType: Option<MediaType> = body.contentType()

            match (mediaType) {
                case Some(contentType) =>
                    arr.write("Content-Type: ".toUtf8Array())
                    arr.write("${contentType}".toUtf8Array())
                    arr.write(CRLF)
                case None => ()
            }

            let contentLength = body.getContentLength()

            if (contentLength != -1) {
                arr.write("Content-Length: ".toUtf8Array())
                arr.write("${contentLength}".toUtf8Array())
                arr.write(CRLF)
            } else {
                if (!write) {
                    arr.clear()
                }
                return -1
            }
            byteCount += contentLength
            arr.write(CRLF)
            if (write) {
                let readArr = Array<Byte>(contentLength, item: 0)
                body.get().read(readArr)
                arr.write(readArr)
            }
            arr.write(CRLF)
        }
        arr.write(DASHDASH)
        arr.write(boundary.toUtf8Array())
        arr.write(DASHDASH)
        arr.write(CRLF)
        byteCount += arr.length
        if (!write) {
            arr.clear()
        }
        return byteCount
    }

    private func writeOrCountBytes(sink: Sink): Unit {

        for (p in 0..parts.size) {
            let part: Part = parts[p]
            let headers = part.headers
            let body = part.body
            sink.write(DASHDASH)
            sink.write(boundary.toUtf8Array())
            sink.write(CRLF)
            match (headers) {
                case Some(h) =>
                    for ((k,v) in h) {
                        for (e in v) {
                            sink.write(k.toUtf8Array())
                            sink.write(COLONSPACE)
                            sink.write(e.toUtf8Array())
                            sink.write(CRLF)
                        }
                    }
                case None => ()
            }

            let mediaType: Option<MediaType> = body.contentType()

            match (mediaType) {
                case Some(contentType) =>
                    sink.write("Content-Type: ".toUtf8Array())
                    sink.write("${contentType}".toUtf8Array())
                    sink.write(CRLF)
                case None => ()
            }

            let contentLength =  body.getContentLength()

            if (contentLength != -1) {
                sink.write("Content-Length: ".toUtf8Array())
                sink.write("${contentLength}".toUtf8Array())
                sink.write(CRLF)
            }

            sink.write(CRLF)
            body.writeTo(sink)
            sink.write(CRLF)
        }
        sink.write(DASHDASH)
        sink.write(boundary.toUtf8Array())
        sink.write(DASHDASH)
        sink.write(CRLF)
    }

    public static func builder(): MultipartBodyBuilder {
        return MultipartBodyBuilder()
    }
}

public class MultipartBodyBuilder <: Builder<MultipartBody> {
    private var contentType: MediaType = MultipartBody.MIXED
    private let parts: ArrayList<Part> = ArrayList<Part>()
    private let boundary: String

    init() {
       this.boundary = randomBoundary()
    }

    public func setType(contentType: MediaType): MultipartBodyBuilder {
        if (contentType.getType() != "multipart") {
            throw IllegalArgumentException("multipart != ${contentType.getType()}")
        }

        this.contentType = contentType
        return this
    }

    public func addPart(part: Part): MultipartBodyBuilder {
        parts.append(part)
        return this
    }

    public func addPart(body: RequestBody): MultipartBodyBuilder {
        return addPart(Part.create(body))
    }

    public func addPart(headers: Header, body: RequestBody): MultipartBodyBuilder {
        return addPart(Part.create(headers, body))
    }

    public func addFormDataPart(name: String, value: String): MultipartBodyBuilder {
        return addPart(Part.createFormData(name, value))
    }

    public func addFormDataPart(name: String, filename: String, body: RequestBody): MultipartBodyBuilder {
        return addPart(Part.createFormData(name, filename, body))
    }

    public func build(): MultipartBody {
        if (parts.isEmpty()) {
            throw IllegalStateException("Multipart body must have at least one part.")
        }
        return MultipartBody(boundary, contentType, parts)
    }
}

public class Part {
    public let headers: Option<Header>
    public let body: RequestBody

    init(headers:Option<Header>, body: RequestBody) {
        this.headers = headers
        this.body = body
    }

    static func create(body: RequestBody): Part {
        return create(Option<Header>.None, body)
    }

    public static func createFormData(name: String, value: String): Part {
        return createFormData(name, "", RealRequestBody.create(Option<MediaType>.None, value))
    }

    public static func create(headers: Option<Header>, body: RequestBody): Part {
        match (headers) {
            case Some(h) =>
                if (hasHeaderKey(h, "Content-Type")) {
                   throw IllegalArgumentException("Unexpected header: Content-Type")
                }

                if (hasHeaderKey(h, "Content-Length")) {
                   throw IllegalArgumentException("Unexpected header: Content-Length")
                }
            case None => ()
        }
        return Part(headers, body)
    }

    public static func createFormData(name: String, filename: String, body: RequestBody): Part {
        if (name.isEmpty()) {
            throw IllegalArgumentException("name is Empty")
        }
        let disposition = StringBuilder("form-data; name=")
        appendQuotedString(disposition, name)
        if (!filename.isEmpty()) {
            disposition.append("; filename=")
            appendQuotedString(disposition, filename)
        }
        checkName(name)
        let headers: Header = Header()
        headers.add("Content-Disposition", "${disposition}")
        return create(headers, body)
    }

    private static func hasHeaderKey(header: Header, key: String): Bool {
        match (header.get(key)) {
            case Some(v) => return true
            case None => return false
        }
    }

    private static func checkName(name: String) {
        for (i in 0..name.toCharArray().size) {
            if (name.charAt(i) <=  '\u{0020}' || name.charAt(i) >= '\u{007f}') {
                throw IllegalArgumentException( "Unexpected char in header name: ${name}")
            }
        }
    }
}

func randomBoundary(): String{
    return "${getTimeStamp(Time.now())}"
}

func appendQuotedString(target: StringBuilder, key: String): Unit {
    target.append('"')
    for (i in 0..key.toCharArray().size) {
        match (key[i]) {
            case '\n' => target.append("%0A")
            case '\r' => target.append("%0D")
            case '"' => target.append("%22")
            case _ =>target.append(key[i])
        }
    }
    target.append('"')
}