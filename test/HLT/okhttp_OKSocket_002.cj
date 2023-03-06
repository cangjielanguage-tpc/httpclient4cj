// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*

@Test
public class okhttp_OKSocket_002 {

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
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
    func okhttp_OKSocket_002(): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)
        var httpRq: http.Request = http.Request(GET,"http://127.0.0.1:${port}/1234")
        httpRq.header.add("Content-Type","multipart/form-data")

        var socketC = SocketC(Socket(TCP, "127.0.0.1", port))
        socketC.connect()
        var okskt = OKSocket(socketC,Option<Duration>.None,Option<Duration>.None)        
        var byteStream = ByteArrayStream()
        httpRq.copyTo(byteStream)
        var str:Array<Byte> = Array<Byte>(300, item: 0)
        var exc = ""
        try{
            okskt.close()
            okskt.write(byteStream.readToEnd())
            okskt.read(str)
            println("str_body = ${String.fromUtf8(str)}")
        }  catch (e: Exception) {
            exc = e.message
        }
        @Assert(exc.contains("The socket is closed."), true)
        @Assert(okskt.isClosed(), true)
    }
}