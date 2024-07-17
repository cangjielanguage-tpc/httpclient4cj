import net.http
import net.http.*
import std.io.*
import std.socket.*
import httpclient4cj
import httpclient4cj.*

foreign func htons(port: UInt16): UInt16
func portTrans(port: UInt16): UInt16 {
    // unsafe { htons(port) }
    port
}

func getRequestMethod(method: String): String {
    println("1.1 ${method}zxc")
    match (method) {
        case "GET" => "GET"
        case "PUT" => "PUT"
        case "POST" => "POST"
        case "HEAD" => "HEAD"
        case "PATCH" => "PATCH"
        case "TRACE" => "TRACE"
        case "DELETE" => "DELETE"
        case "CONNECT" => "CONNECT"
        case "OPTIONS" => "OPTIONS"
        case _ => throw IllegalArgumentException("no such method")
    }
}
// extend Header {
//     func clone(): Header {
//         let header = Header()
//         for ((k, v) in this) {
//             header.set(k, v)
//         }
//         header
//     }
// }
extend http.HttpRequest {
    func copyTo(stream: OutputStream): Unit {
        let bytes = this.toString().toArray()
        stream.write(bytes)
    }
}
public func toHttpRequest(request: httpclient4cj.Request): http.HttpRequest {
    let method = getRequestMethod(request.getMethod())
    let header = request.getHeaders()
    let url = request.getUrl()
    let req = HttpRequestBuilder().method(method).url(url)
    for ((k, vs) in header.clone()) {
        for (v in vs) {
            req.header(k, v)
        }
    }
    match (request.getBody()) {
        case Some(v) => req.body(v.get())
        case _ => ()
    }
    return req.build()
}
