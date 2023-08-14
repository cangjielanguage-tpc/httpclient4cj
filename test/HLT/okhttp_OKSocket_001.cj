// 3rd_party_lib:httpclient4cj/build/httpclient4cj

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep

@Test
public class okhttp_OKSocket_001 {
    var port: UInt16 = 0
    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register(
            "/1234",
            {
                httpContext =>
                let resp = "Hello from /red".toUtf8Array()
                httpContext.responseBuilder.body(resp)
                httpContext.responseBuilder.header("content-type", "text/plain; charset=utf-8")
                return
            }
        )
        spawn {server.serve()}
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }
    @TestCase
    func okhttp_OKSocket_001(): Unit {
        serve()
        var httpRq: HttpRequest = HttpRequestBuilder.new()
            .get()
            .url("http://127.0.0.1:${port}/1234")
            .header("host", "127.0.0.1:${port}")
            .header("Content-Type", "multipart/form-data")
            .build()

        var socketC = SocketC(TcpSocket("127.0.0.1", port))
        socketC.connect()
        var okskt = OKSocket(socketC, Option<Duration>.None, Option<Duration>.None)
        var byteStream = ByteArrayStream()
        httpRq.copyTo(byteStream)
        var str: Array<Byte> = Array<Byte>(300, item: 0)
        okskt.write(byteStream.readToEnd())
        okskt.read(str)
        var str_body = String.fromUtf8(str)
        println("str_body = ${str_body}")
        @Assert(str_body.contains("HTTP/1.1 200 OK"), true)
        @Assert(str_body.contains("date: "), true)
        @Assert(str_body.contains(" GMT"), true)
        @Assert(str_body.contains("content-length: 15"), true)
        @Assert(str_body.contains("connection: keep-alive"), true)
        @Assert(str_body.contains("content-type: text/plain; charset=utf-8"), true)
        @Assert(str_body.contains("Hello from /red"), true)
    }
}
extend http.HttpRequest {
    func copyTo(stream: OutputStream): Unit {
        println(this.toString())
        let bytes = this.toString().toUtf8Array()
        stream.write(bytes)
    }
}
