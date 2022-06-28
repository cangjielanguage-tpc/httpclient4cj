/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Request class.
 */
package okhttp
from net import http.*
from encoding import url.*

/**
 * The class is Request
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Request {
    /* var member url type is URL */
    var url: URL
    /* var member header type is Header */
    var header: Header
    /* var member method type is String */
    var method: String

    /**
     * The Function is init constructor
     *
     * @param builder of RequestBuilder
     * @since 0.29.3
     */
    public init(builder: RequestBuilder) {
        this.url = builder.urlBuild
        this.header = builder.headerBuild
        this.method = builder.methodBuild
    }
    /**
     * The Function is getUrl
     *
     * @return Type of URL
     * @since 0.29.3
     */
    public func getUrl(): URL {
        return url
    }

    /**
     * The Function is getMethod
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func getMethod(): String {
        return method
    }


    /**
     * The Function is builder
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public static func builder(): RequestBuilder{
        return RequestBuilder()
    }
}
