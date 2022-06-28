/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ResponseBody class.
 */
package okhttp
from std import io.*
from net import http.*

/**
 * The class is ResponseBody
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ResponseBody {
    /* var member source type is BufferStream */
    var source: BufferStream

    /**
     * The Function is init constructor
     *
     * @param source of BufferStream
     * @since 0.29.3
     */
    public init(source: BufferStream)     {
        this.source = source
    }

    /**
     * The Function is getSource
     *
     * @return Type of BufferStream
     * @since 0.29.3
     */
    public func getSource(): BufferStream {
        return source
    }

    /**
     * The Function is close
     *
     * @since 0.29.3
     */
    public func close() {
        Util.closeQuietly(source)
    }
}






