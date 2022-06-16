package okhttp
from net import http.*
from encoding import url.*

public class Request {
    var url: URL
    var header: Header
    var method: String

    public init(builder: RequestBuilder) {
        this.url = builder.urlBuild
        this.header = builder.headerBuild
        this.method = builder.methodBuild
    }
    public func getUrl(): URL {
        return url
    }

    public func getMethod(): String {
        return method
    }


    public static func builder(): RequestBuilder{
        return RequestBuilder()
    }
}
