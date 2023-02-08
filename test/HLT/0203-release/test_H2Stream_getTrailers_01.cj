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
from http2 import buffer.*
from http2 import common.*
from http2 import frame.*
from http2 import hpack.*
from http2 import proto.*
from std import log.*

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
public class okhttp_H2Stream_01{
    public override func beforeAll(): Unit {
        spawn{
            serve()
        }
        sleep(3*1000*1000*1000)
        println("port=${port}")
    }

    @TestCase
    func okhttp_getTrailers_001(): Unit {
        let formBody = FormBody.builder()
                            .add("username", "admin")
                            .add("password", "123456")
                            .add("host","%6D")
                            .build()
        let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example").put(formBody)
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()
        let soc = Socket(TCP,"127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))

        h2conn.start()
        let h2stream = h2conn.newStream(request)
        /*let sink = h2stream.getSink()
        let trailers = Header()
        trailers.set("123", "ttt")
        h2stream.enqueueTrailers(trailers)
        formBody.writeTo(sink)
        sink.close()*/

        //var h2stream=h2conn.newStream(request)
        var ba=ByteArrayStream()
        var arr01=Array<Byte>(100,item:8)
        ba.write(arr01)
        h2conn.writeData(h2stream.getId(),true,ba,100)
        //var source=h2stream.getSource()
       // println("source.read(ba,1000)=${source.read(ba,1000)}")
       //source.close()
        var headers=h2stream.getTrailers()
        /*
        for ((k,v) in headers){
            println("k=${k}")
            println("v=${v[0]}")
        }*/
       // @Assert(h2stream.getTrailers().getKeysToString(),"")
    }
}