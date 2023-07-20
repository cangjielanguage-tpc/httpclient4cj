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
from std import unittest.*
from std import unittest.testmacro.*

var port: UInt16 = 0
main() {
    serve()
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient = HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    println(response.toString())
    @Assert(response.toString().contains("Internal Server Error"))
    return 0
}

func serve() {
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder.new().listener(serverSocket).build()
    server.distributor.register("/1234",
        {
        httpContext =>
        println(1.1)
        httpContext.responseBuilder.header("", "test")
        println(1.2)
        return
    })
    spawn {server.serve()}
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}
