// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
import net.http.*
import net.tls.*
import std.socket.*
import httpclient4cj
import httpclient4cj.*
import std.io.*
import std.time.*

main() {
    var cfg = TlsClientConfig()
    cfg.verifyMode = TrustAll
    let s = TcpSocket("www.jd.com", portTrans(443))
    s.connect()
    let socket = TlsSocket.client(s, clientConfig: cfg)
    socket.handshake()
    println(socket.isClosed())
    let socketC = TlsC(socket)
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://36.152.44.95/index.html")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let requestStream = ByteArrayStream()
    let req4cj = toHttpRequest(request)
    req4cj.copyTo(requestStream)
    socketC.write(requestStream.readToEnd())
    var readBuf: Array<Byte> = Array<Byte>(1024, item: 0)
    socketC.read(readBuf)
    println(String.fromUtf8(readBuf))
    socketC.close()
    0
}
// public func toHttpRequest(request: httpclient4cj.Request): http.HttpRequest {
//     let method = getRequestMethod(request.getMethod())
//     let header = request.getHeaders()
//     let url = request.getUrl()
//     let req = match (request.getBody()) {
//         case Some(v) => HttpRequestBuilder().method(method).url(url).body(v.get())
//         case _ => HttpRequestBuilder().method(method).url(url)
//     }
//     for ((k, vs) in header.clone()) {
//         for (v in vs) {
//             req.header(k, v)
//         }
//     }
//     return req.build()
// }

// func getRequestMethod(method: String): String {
//     match (method) {
//         case "GET" => "GET"
//         case "PUT" => "PUT"
//         case "POST" => "POST"
//         case "HEAD" => "HEAD"
//         case "PATCH" => "PATCH"
//         case "TRACE" => "TRACE"
//         case "DELETE" => "DELETE"
//         case "CONNECT" => "CONNECT"
//         case "OPTIONS" => "OPTIONS"
//         case _ => throw IllegalArgumentException("no such method")
//     }
// }
// extend Header {
//     func clone(): Header {
//         let header = Header()
//         for ((k, v) in this) {
//             header.set(k, v)
//         }
//         header
//     }
// }
// extend http.HttpRequest {
//     func copyTo(stream: OutputStream): Unit {
//         let bytes = this.toString().toArray()
//         stream.write(bytes)
//     }
// }
