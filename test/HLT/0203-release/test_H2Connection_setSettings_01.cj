// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


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
from std import log.*

public var port:UInt16=36389

@Test
public class okhttp_H2Connection_01{

    @TestCase
    func okhttp_setSettings_001(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        var s01=Settings()
        s01.setting(1,100)
        s01.setting(2,200)
        s01.setting(4,400)
        s01.setting(5,500)
        s01.setting(6,600)
        s01.setting(7,700)
        h2conn.setSettings(s01)
        @Assert(s01.isSet(1),true)
        @Assert(s01.isSet(2),true)
        @Assert(s01.isSet(4),true)
        @Assert(s01.isSet(5),true)
        @Assert(s01.isSet(6),true)
        @Assert(s01.isSet(7),true)
    }
}