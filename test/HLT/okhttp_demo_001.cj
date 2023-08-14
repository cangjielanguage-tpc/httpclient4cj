// 3rd_party_lib:httpclient4cj/build/httpclient4cj

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
from std import sync.sleep

@Test
public class okhttp_demo {
    var port: UInt16 = 0
    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1235",
            {
            httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            httpContext.responseBuilder.header("Content-type","text/plain; charset=utf-8")
            return
        })
        spawn {server.serve()}
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_demo(): Unit {
        serve()

        let cache: CacheControl = CacheControl.builder().maxAge(1000).build()
        let client: HttpClient = HttpClient.builder().build()
        // let body: httpclient4cj.RequestBody = httpclient4cj.RequestBody("Media-Type", "text/html")
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
            .url("http://127.0.0.1:${port}/1235")
            .method("GET") //加body
            .cacheControl(cache)
            .build()
        var call = client.newCall(request)
        var response: httpclient4cj.Response = call.execute()
        var response_heads: Header = response.getHeaders()
        // var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
        // var str =String.fromUtf8(response_body)
        var response_protocol = response.getProtocol().toString()
        var response_code: Int64 = response.getCode()
        var response_isSuccess: Bool = response.isSuccess()

        println("-------------------------------OKHttp-Response_Header----------------------------")
        for ((nm, vl) in response_heads) {
            println(nm)
            println(vl)
        }
        println("protocol = ${response_protocol}")
        println("code = ${response_code}")
        println("isSuccess = ${response_isSuccess}")

        @Assert(response_code,Int64(200))
        // @Assert(str, "Hello from /red")
        // @Assert(response_body, "Hello from /red".toUtf8Array())
        @Assert(response.getHeader("Content-Length").getOrThrow(),"15")
        @Assert(response.getHeader("Date").getOrThrow().contains("GMT"),true)
        @Assert(response.getHeader("Connection").getOrThrow(),"keep-alive")
        @Assert(response.getHeader("Content-Type").getOrThrow(),"text/plain; charset=utf-8")
        @Assert(response_protocol,"http/1.1")

        //@Assert(response_isSuccess,true)

    }
}

@Test
public class http_demo {
    var port: UInt16 = 1104
    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234",
            {
            httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn {server.serve()}
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func http_demo(): Unit {
        serve()
        let client = ClientBuilder.new().build()
        var a: http.HttpResponse = client.get("http://127.0.0.1:${port}/1234")
        var byteStream = ByteArrayStream()
        a.copyTo(byteStream)
        var str = StringReader(a.body).readToEnd()
        var str_Response = String.fromUtf8(byteStream.readToEnd())

        println("------------------------------------Http-Response--------------------------------")
        println(str_Response)

        //println("http.Response.body")
        //println(str)
        @Assert(str, "Hello from /red")
        //@Assert(str, "404 page not found")
    }
}

extend http.HttpResponse {
    func copyTo(stream: OutputStream): Unit {
        println(this.toString())
        let bytes = this.toString().toUtf8Array()
        stream.write(bytes)
    }
}
