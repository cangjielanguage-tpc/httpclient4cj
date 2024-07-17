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
public class okhttp_OKSocket_002 {
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
                return
            }
        )
        spawn {server.serve()}
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }
    @TestCase
    func okhttp_OKSocket_002(): Unit {
        serve()
        var httpRq: HttpRequest = HttpRequestBuilder().get().url("http://127.0.0.1:${port}/1234").header(
            "host",
            "127.0.0.1:${port}"
        ).header("Content-Type", "multipart/form-data").build()

        var socketC = SocketC(TcpSocket("127.0.0.1", port))
        socketC.connect()
        var okskt = OKSocket(socketC, Option<Duration>.None, Option<Duration>.None)
        var byteStream = ByteArrayStream()
        httpRq.copyTo(byteStream)
        var str: Array<Byte> = Array<Byte>(300, item: 0)
        var exc = ""
        try {
            okskt.close()
            okskt.write(byteStream.readToEnd())
            okskt.read(str)
            println("str_body = ${String.fromUtf8(str)}")
        } catch (e: Exception) {
            exc = e.message
        }
        println(exc)
        @Assert(exc.toAsciiLower().contains("socket is already closed"), true)
        @Assert(okskt.isClosed(), true)
    }
}
extend http.HttpRequest {
    func copyTo(stream: OutputStream): Unit {
        println(this.toString())
        let bytes = this.toString().toArray()
        stream.write(bytes)
    }
}
