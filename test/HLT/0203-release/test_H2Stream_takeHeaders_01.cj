// 3rd_party_lib:okhttp/build/okhttp


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
from std import log.*

public var port:UInt16=36389

@Test
public class okhttp_H2Stream_01{

    @TestCase
    func okhttp_takeHeaders_001(): Unit {
        let formBody = FormBody.builder()
                            .add("username", "admin")
                            .add("password", "123456")
                            .add("host","%6D")
                            .build()
        let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example")
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))

        h2conn.start()
        let stream = h2conn.newStream(request)
        var allKeys=stream.takeHeaders()
        var headers=""
        for((k,v) in allKeys) {
            headers=headers+k+":"+v[0]+"  "
        }
        @Assert(headers.contains("status"))
        @Assert(headers.contains("Content-Type"))
        @Assert(headers.contains("Content-Length"))
        @Assert(headers.contains("Date"))
    }
}