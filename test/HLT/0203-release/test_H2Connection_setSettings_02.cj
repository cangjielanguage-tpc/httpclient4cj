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
    func okhttp_setSettings_002(): Unit {
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
        var s01=Settings()
        var s02=Settings()
        s01.setting(1,100)
        s01.setting(2,200)
        s01.setting(4,400)
        s01.setting(5,500)
        s01.setting(6,600)
        s01.setting(7,700)
        h2conn.setSettings(s01)
        h2conn.setSettings(s02)
        @Assert(s01.isSet(1),true)
        @Assert(s01.isSet(2),true)
        @Assert(s01.isSet(4),true)
        @Assert(s01.isSet(5),true)
        @Assert(s01.isSet(6),true)
        @Assert(s01.isSet(7),true)
        @Assert(s02.isSet(1),false)
        @Assert(s02.isSet(2),false)
        @Assert(s02.isSet(4),false)
        @Assert(s02.isSet(5),false)
        @Assert(s02.isSet(6),false)
        @Assert(s02.isSet(7),false)
    }
}