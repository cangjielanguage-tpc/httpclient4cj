// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.log.*
import std.sync.sleep

public var port:UInt16=portTrans(36389)

@Test
public class okhttp_H2Connection_01{
    @TestCase
    func okhttp_close_001(): Unit {

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
