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
public class okhttp_H2Connection_01{

    @TestCase
    func okhttp_openStreamCount_003(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        let formBody = FormBody.builder()
                            .add("username", "admin")
                            .add("password", "123456")
                            .add("host","%6D")
                            .build()
        let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example").put(formBody)
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()
        h2conn.start()
        var h2stream02=h2conn.newStream(request)
        var h2stream03=h2conn.newStream(request)
        var h2stream04=h2conn.newStream(request)
        @Assert(h2conn.openStreamCount(),3)
    }
}