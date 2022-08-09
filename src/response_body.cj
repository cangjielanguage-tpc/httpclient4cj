/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ResponseBody class.
 */
package okhttp
from std import io.*

/**
 * The class is ResponseBody
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ResponseBody {
    /* var member source type is StringStream */
    var source: ByteArrayStream = ByteArrayStream()
    /* var member contentType type is String */
    var contentType:String = ""
    /* var member contentLength type is Int64 */
    var contentLength: Int64 = 0

    /**
     * The Function is init constructor
     *
     * @param contentType of String
     * @param contentLength of Int64
     * @param source of StringStream
     * @since 0.29.3
     */
    public init(contentType: String, contentLength: Int64, source: ByteArrayStream) {
        this.source = source
        this.contentType = contentType
        this.contentLength = contentLength
    }

    /**
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    public init(){}

    /**
     * The Function is getSource
     *
     * @return Type of StringStream
     * @since 0.29.3
     */
    public func getSource(): ByteArrayStream {
        return source
    }

    /**
     * The Function is close
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func close(): Unit {

    }

    public func getContentLength(): Int64 {
        return contentLength
    }

  /**
     * The Function is contentType
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func getContentType(): String {
        return contentType
    }
}






