// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj

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
public class okhttp_OKSocket_001{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }
    @TestCase
    func okhttp_OKSocket_001(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)
    var httpRq: http.Request = http.Request(GET,"http://127.0.0.1:${port}/1234")
    httpRq.header.add("Content-Type","multipart/form-data")

    var socketC = SocketC(Socket(TCP, "127.0.0.1", port))
    socketC.connect()
    var okskt = OKSocket(socketC,Option<Duration>.None,Option<Duration>.None)        
    var byteStream = ByteArrayStream()
    httpRq.copyTo(byteStream)
    var str:Array<Byte> = Array<Byte>(300, item: 0)
    okskt.write(byteStream.readToEnd())
    okskt.read(str)
    var str_body = String.fromUtf8(str)
    println("str_body = ${str_body}")
    @Assert(str_body.contains("HTTP/1.1 200 OK"), true)
    @Assert(str_body.contains("Date: "), true)
    @Assert(str_body.contains(" GMT"), true)
    @Assert(str_body.contains("Content-Length: 15"), true)
    @Assert(str_body.contains("Connection: keep-alive"), true)
    @Assert(str_body.contains("Content-Type: text/plain; charset=utf-8"), true)
    @Assert(str_body.contains("Hello from /red"), true)
    }
}