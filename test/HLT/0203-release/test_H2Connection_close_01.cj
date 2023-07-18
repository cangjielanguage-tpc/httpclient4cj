// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import log.*
from std import sync.sleep

public var port:UInt16=36389

@Test
public class okhttp_H2Connection_01{
    @TestCase
    func okhttp_close_001(): Unit {

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
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                            .header("User-Agent", "OkHttp-Example").put(formBody)
                                                            .header("content-type",formBody.contentType().getOrThrow().toString())
                                                            .build()

        h2conn.start()
        var h2stream=h2conn.newStream(request)
        var ba=ByteArrayStream()
        var arr01=Array<Byte>(100,item:8)
        ba.write(arr01)
        @Assert(h2conn.isHealthy(),true)
        h2conn.close()
        @Assert(h2conn.isHealthy(),false)
        @Assert(h2stream.getErrorCode().getOrThrow().toString(),"CANCEL")
        @Assert(h2stream.getErrorCode().getOrThrow().getCode(),8)
        sleep(5*Duration.second)
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
