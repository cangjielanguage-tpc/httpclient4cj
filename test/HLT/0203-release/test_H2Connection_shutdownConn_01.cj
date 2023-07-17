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
from std import log.*

public var port:UInt16=36389

@Test
public class okhttp_H2Connection_01{

    @TestCase
    func okhttp_shutdownConn_001(): Unit {

        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.NO_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_002(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.PROTOCOL_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_003(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.INTERNAL_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_004(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.FLOW_CONTROL_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_005(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.REFUSED_STREAM)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_006(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.CANCEL)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_007(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.COMPRESSION_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_008(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.CONNECT_ERROR)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_009(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.ENHANCE_YOUR_CALM)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_010(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.INADEQUATE_SECURITY)
        @Assert(h2conn.isHealthy(),false)
    }
    @TestCase
    func okhttp_shutdownConn_011(): Unit {
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        @Assert(h2conn.isHealthy(),true)
        h2conn.shutdownConn(ErrorCode.HTTP_1_1_REQUIRED)
        @Assert(h2conn.isHealthy(),false)
    }
}