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
    public var urlBuild: URL = URL.parse("")
    /** var member headerBuild type is Header */
    public var headerBuild: Header = Header()
    /** var member methodBuild type is String */
    public var methodBuild: String = "GET"
    /** var member bodyBuild type is Option<RequestBody> */
    public var bodyBuild:  Option<RequestBody> = Option<RequestBody>.None

    // TODO TAGS
    /**
     * The Function is init constructor
     *
     * @param request of Request
     * @since 0.29.3
     */
    public init(request: Request) {
        this.urlBuild = request.getUrl()
        this.methodBuild = request.getMethod()
        this.bodyBuild = request.getBody()
        this.headerBuild = request.getHeaders()

    }

    /**
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    public init() {}

    /**
     * The Function is url
     *
     * @param url of String
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func url(url: String): RequestBuilder {
        this.urlBuild = URL.parse(url)
        return this
    }

    /**
     * The Function is url
     *
     * @param url of URL
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func url(url: URL): RequestBuilder {
        this.urlBuild = url
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
     * The Function is body
     *
     * @param requestBody of RequestBody
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func body(requestBody: RequestBody): RequestBuilder {
        this.bodyBuild = Option<RequestBody>.Some(requestBody)
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

    /**
     * The Function is removeHeader
     *
     * @param name of String
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func removeHeader(name: String): Unit {
        headerBuild.remove(name)
    }

    /**
     * The Function is header
     *
     * @param header of Header
     * @since 0.29.3
     */
    public func header(header: Header) {
        this.headerBuild = header
    }

}
