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
import std.sync.*

public var port: UInt16 = portTrans(36389)

@Test
public class okhttp_H2Stream_01 {
    @TestCase
    func okhttp_getTrailers_001(): Unit {
        let formBody = FormBody.builder()
            .add("username", "admin")
            .add("password", "123456")
            .add("host", "%6D")
            .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
            .url("http://127.0.0.1:${port}/foo")
            .header("User-Agent", "OkHttp-Example")
            .put(formBody)
            .header("content-type", formBody.contentType().getOrThrow().toString())
            .build()

        let soc = TcpSocket("127.0.0.1", port)
        soc.connect()
        let sc = SocketClient.SocketC(soc)
        let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)

        let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
        h2conn.start()
        let h2stream = h2conn.newStream(request)

        var ba = ByteArrayStream()
        var arr01 = Array<Byte>(100, item: 8)
        ba.write(arr01)

        h2conn.writeData(h2stream.getId(), true, ba, 100)
        var source = h2stream.getSource()
        source.read(ba, 1000)
        source.close()

        sleep(Duration.second)
        var headers = h2stream.getTrailers()
        var headersStr = ""
        for ((k, v) in headers) {
            headersStr = headersStr + k + "" + v[0]
        }
        @Assert(headersStr,"")
    }
}
