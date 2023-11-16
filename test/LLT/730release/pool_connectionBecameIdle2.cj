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
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        let resp = "Hello from /red".toArray()
        //解析错误, 连接设置为不再使用
        httpContext.responseBuilder.header("Transfer-Encoding","chunked")
        //httpContext.responseBuilder.header("Myhost","1111\r\n\r\n222444\n122;")
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
    spawn {
    }
    sleep(Duration.second)

    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .build()
    try{
        let call = client.newCall(request)
        let response: httpclient4cj.Response = call.execute()
        println(response.isSuccess())
    } catch (e: Exception) {
        return 1
    }
    return 0
}