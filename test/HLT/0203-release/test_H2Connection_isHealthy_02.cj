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
from std import log.*

public var port:UInt16=36389

@Test
public class okhttp_H2Connection_01{
    @TestCase
    func okhttp_isHealthy_002(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.close()
        @Assert(h2conn.isHealthy(),false)
    }
}