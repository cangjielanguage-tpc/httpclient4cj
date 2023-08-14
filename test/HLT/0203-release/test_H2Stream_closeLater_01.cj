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

public var port:UInt16=portTrans(36389)

@Test
public class okhttp_H2Stream_01{

    @TestCase
    func okhttp_closeLater_001(): Unit {
        let soc = TcpSocket("127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        let formBody = FormBody.builder()
                            .add("username", "admin")
                            .add("password", "123456")
                            .add("host","%6D")
                            .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example").put(formBody)
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()
        h2conn.start()
        var h2stream=h2conn.newStream(request)
        @Assert(h2stream.isOpen(),true)
        h2stream.closeLater(ErrorCode.NO_ERROR)
        @Assert(h2stream.isOpen(),false)
        @Assert(h2stream.getErrorCode().getOrThrow().toString().contains("NO_ERROR"),true)
    }
    @TestCase
    func okhttp_closeLater_002(): Unit {
        let soc = TcpSocket("127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        let formBody = FormBody.builder()
                            .add("username", "admin")
                            .add("password", "123456")
                            .add("host","%6D")
                            .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example").put(formBody)
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()
        h2conn.start()
        var h2stream=h2conn.newStream(request)
        @Assert(h2stream.isOpen(),true)
        h2stream.closeLater(ErrorCode.HTTP_1_1_REQUIRED)
        @Assert(h2stream.isOpen(),false)
        @Assert(h2stream.getErrorCode().getOrThrow().toString().contains("HTTP_1_1_REQUIRED"),true)
    }
}