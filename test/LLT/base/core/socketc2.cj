// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from net import http.*
from net import tls.*
from std import socket.*
from httpclient4cj import httpclient4cj.*
from std import io.*
from std import time.*
main() {
   var cfg = TlsClientConfig("")
   cfg.verifyMode = VerifyNone
   let socket = TlsSocket(TCP,"www.jd.com", 443, cfg)
   socket.connect()
   println(socket.isClosed())
   let socketC = TlsC(socket)
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let requestStream = ByteArrayStream()
    let req4cj =  toHttpRequest(request)
    req4cj.copyTo(requestStream)
    socketC.write(requestStream.readToEnd())
    var readBuf: Array<Byte> = Array<Byte>(1024, item: 0)
    socketC.read(readBuf)
    println(String.fromUtf8(readBuf))
    socketC.close()
    0
}
public func toHttpRequest(request: httpclient4cj.Request): http.Request{
 let method = getRequestMethod(request.getMethod())
 let header = request.getHeaders()
 let url = request.getUrl()
 let req = match (request.getBody()) {
     case Some(v) =>  http.Request(method, url.toString(), v.get())
     case _ =>  http.Request(method, url.toString())
 }
 req.header = header.clone()
 return req
}

func getRequestMethod(method: String): RequestMethod {
    match (method) {
        case "GET" => GET
        case "PUT" => PUT
        case "POST" => POST
        case "HEAD" => HEAD
        case "PATCH" => PATCH
        case "TRACE" => TRACE
        case "DELETE" => DELETE
        case "CONNECT" => CONNECT
        case "OPTIONS" => OPTIONS
        case _ => throw IllegalArgumentException("no such method")
    }

}
