/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the RequestBody class.
 */
package okhttp

/**
 * The class is RequestBody
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class RequestBody {
    /* var member content type is String */
    private let buffer: ByteArrayStream = ByteArrayStream()
    /* var member MediaType type is String */
    private var mediaType: String
    private let contentLength: Int64
    /*
     * The Function is init constructor
     *
     * @param MediaType of String
     * @param content of String
     * @since 0.29.3
     */
   public init(mediaType: String, bytes: Array<Byte>) {
        contentLength = bytes.size
        this.buffer.write(bytes)
        this.mediaType = mediaType
    }

    /**
     * The Function is contentType
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func contentType(): String {
        return mediaType

    }

    /**
     * The Function is contentLength
     *
     * @return Type of Int64
     * @since 0.29.3
     */
   public func getContentLength(): Int64 {
        return contentLength

   }

   public func writeTo(sink: Sink): Unit {
       sink.write(buffer.readToEnd())
   }

    /**
     * The Function is get
     *
     * @return Type of ReadCloseStream
     * @since 0.29.3
     */
    public func get(): InputStream {
        return buffer
    }


    public static func create(contentType: String, content: String): RequestBody {
        return create(contentType, content.toUtf8Array())
    }

    public static func create(contentType: String, bytes: Array<Byte>): RequestBody {
        return RequestBody(contentType, bytes)
    }

    public static func create(contentType: String, file: File): RequestBody {
        return create(contentType, file.readToEnd())
    }

}