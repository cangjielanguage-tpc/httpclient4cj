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
    func okhttp_shutdownConn_003(): Unit {

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
        var h2stream=h2conn.newStream(request)
        var ba=ByteArrayStream()
        var arr01=Array<Byte>(100,item:8)
        ba.write(arr01)
        h2conn.shutdownConn(ErrorCode.INADEQUATE_SECURITY)
        sleep(3*1000*1000*1000)
        var flag=0
        try{
            h2conn.writeData(h2stream.getId(),true,ba,100)
        }catch(e:Exception){
            @Assert(e.toString().contains("close"),true)
            flag=1
        }
        @Assert(flag,1)

    }
}