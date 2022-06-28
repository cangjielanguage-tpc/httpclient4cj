/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the RequestBuilder class.
 */
package okhttp
from net import http.*
from encoding import url.*

/**
 * The class is RequestBuilder inherited from Builder<Request>
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class RequestBuilder <: Builder<Request> {
    /** var member urlBuild type is URL */
    public var urlBuild: URL = URL.parse("").getOrThrow()
    /** var member headerBuild type is Header */
    public var headerBuild: Header = Header()
    /** var member methodBuild type is String */
    public var methodBuild: String = ""

    /**
     * The Function is url
     *
     * @param url of String
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func url(url: String): RequestBuilder {
        if (url.isEmpty()) {
            throw Exception("url == null")
        }
        this.urlBuild = URL.parseRequestURI(url).getOrThrow()
        return this
    }

    /**
     * The Function is header
     *
     * @param name of String
     * @param value of String
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func header( name: String, value: String): RequestBuilder {
        headerBuild.set(name, value)
        return this
    }

    /**
     * The Function is method
     *
     * @param method of String
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func method(method: String): RequestBuilder {
        this.methodBuild = method
        return this
    }

    /**
     * The Function is build
     *
     * @return Type of Request
     * @since 0.29.3
     */
    public func build(): Request {
        return Request(this)
    }


}
