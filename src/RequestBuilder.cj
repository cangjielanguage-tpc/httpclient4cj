package okhttp
from net import http.*
from encoding import url.*

public class RequestBuilder <: Builder<Request> {
    public var urlBuild: URL = URL.parse("").getOrThrow()
    public var headerBuild: Header = Header()
    public var methodBuild: String = ""

    public func url(url: String): RequestBuilder {
        if (url.isEmpty()) {
            throw Exception("url == null")
        }
        this.urlBuild = URL.parseRequestURI(url).getOrThrow()
        return this
    }

    public func header( name: String, value: String): RequestBuilder {
        headerBuild.set(name, value)
        return this
    }

    public func method(method: String): RequestBuilder {
        this.methodBuild = method
        return this
    }

    public func build(): Request {
        return Request(this)
    }


}
