// 3rd_party_lib:httpclient4cj/build/httpclient4cj

import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.sync.sleep

@Test
public class okhttp_OKSocket_003 {
    var port: UInt16 = 0
    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register(
            "/1234",
            {
                httpContext =>
                let resp = "Hello from /red".toArray()
                httpContext.responseBuilder.body(resp)
                httpContext.responseBuilder.header("Content-Type","text/plain; charset=utf-8")
                return
            }
        )
        spawn {server.serve()}
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }
    @TestCase
    func okhttp_OKSocket_003(): Unit {
        serve()
        var httpRq: HttpRequest = HttpRequestBuilder()
            .get()
            .url("http://127.0.0.1:${port}/1234")
            .header("host", "127.0.0.1:${port}")
            .header("Content-Type", "multipart/form-data")
            .build()
        var minute2 = Duration.minute * 2
        var minute3 = Duration.minute * 3
        var socketC = SocketC(TcpSocket("127.0.0.1", port))
        socketC.connect(minute2)
        var okskt = OKSocket(socketC, minute2, minute3)
        var byteStream = ByteArrayStream()
        httpRq.copyTo(byteStream)
        var str: Array<Byte> = Array<Byte>(300, item: 0)
        okskt.write(byteStream.readToEnd())
        okskt.read(str)
        var str_body = String.fromUtf8(str)
        println("str_body = ${str_body}")
        @Assert(str_body.contains("HTTP/1.1 200 OK"), true)
        @Assert(str_body.contains("date: "), true)
        @Assert(str_body.contains(" GMT"), true)
        @Assert(str_body.contains("content-length: 15"), true)
        @Assert(str_body.contains("connection: keep-alive"), true)
        @Assert(str_body.toAsciiLower().contains("content-type: text/plain; charset=utf-8"), true)
        @Assert(str_body.contains("Hello from /red"), true)
    }
}
extend http.HttpRequest {
    func copyTo(stream: OutputStream): Unit {
        println(this.toString())
        let bytes = this.toString().toArray()
        stream.write(bytes)
    }
}
