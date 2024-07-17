// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
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
    func okhttp_getMaxConcurrentStreams_002(): Unit {
        let soc = TcpSocket("127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        var s02=Settings()
        s02.setting(4,400)
        h2conn.setSettings(s02)
        @Assert(h2conn.getMaxConcurrentStreams(),100)
        sleep(10*Duration.second)
    }
}