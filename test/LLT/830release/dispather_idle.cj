// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep

var port: UInt16 = 0
main() {
    serve()
    let d = Dispatcher()
    d.setIdleCallback({=> println("123")})
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient= HttpClient.builder().dispatcher(d).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .header("Accept-Encoding","")
                                    .build()
    let call = client.newCall(request)

    let response: httpclient4cj.Response = call.execute()
    match (response.getBody()) {
        case Some(b) =>
            b.getContentType()
            return 0
        case None => return -1
    }
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.header("Content-Encoding","gzip")
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}