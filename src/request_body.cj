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
    private var content: String
    /* var member MediaType type is String */
    private var mediaType: String

    /*
     * The Function is init constructor
     *
     * @param MediaType of String
     * @param content of String
     * @since 0.29.3
     */
   public init(mediaType: String, content: String) {
        this.content = content
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
    public func contentLength(): Int64 {
        return content.size

    }

    /**
     * The Function is get
     *
     * @return Type of ReadCloseStream
     * @since 0.29.3
     */
    public func get(): InputStream {
        let stream = ByteArrayStream()
        stream.write(content.toUtf8Array())
        return stream
    }

}