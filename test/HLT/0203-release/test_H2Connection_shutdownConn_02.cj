// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/build/http2

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
from http2 import buffer.*
from http2 import common.*
from http2 import frame.*
from http2 import hpack.*
from http2 import proto.*

public var port:UInt16=0
public var h2t: H2Transport = H2Transport()
public var c2 = MultiClient(h2t)
public let TEST_STR: String = "http2 server write"

public func serve():Unit{
    let hd = http.Route()
    hd.handle("/foo", { w, r => // ResponseWriteStream, request
        let str: String = TEST_STR
        w.write(str.toUtf8Array())
    })
    let server = MultiServer(hd, Http2Cfg(http2: true, logLevel: DEBUG))
    let socket = SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}

@Test
public class okhttp_H2Connection_01{
    public override func beforeAll(): Unit {
        spawn{
            serve()
        }
        sleep(3*1000*1000*1000)
        println("port=${port}")
    }

    @TestCase
    func okhttp_shutdownConn_001(): Unit {

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
        h2conn.shutdownConn(ErrorCode.INADEQUATE_SECURITY)
        var flag=0
        try{
            var h2stream02=h2conn.newStream(request)
        }catch(e:Exception){
            @Assert(e.toString().contains("shutdown"),true)
            flag=1
        }
        @Assert(flag,1)
        sleep(10*1000*1000)

    }
}