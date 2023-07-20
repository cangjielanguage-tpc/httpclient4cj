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
public class okhttp_Response_001{

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            httpContext.responseBuilder.header("Content-Type","text/plain; charset=utf-8")
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_Response_001(): Unit {
        serve()

        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(1000)
                                    .build()
        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("GET")
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        var response: httpclient4cj.Response = call.execute()
        response.getRequest()
        var response_heads: Header = response.getHeaders()
        var response_protocol = response.getProtocol().toString()
        var response_code : Int64 = response.getCode()
        var response_isSuccess:Bool= response.isSuccess()
        var responseStr:String = response.toString()


        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }
        println("protocol = ${response_protocol}")
        println("code = ${response_code}")
        println("isSuccess = ${response_isSuccess}")

        @Assert(response_code,Int64(200))
        @Assert(response.getHeader("aaa").toString(),"None")
        @Assert(response.getHeader("bbb","123"),"123")
        @Assert(response.getHeader("Content-Length"),"15")
        @Assert(response.getHeader("Date").toString().contains("GMT"),true)
        @Assert(response.getHeader("Connection"),"keep-alive")
        @Assert(response.getHeader("Content-Type"),"text/plain; charset=utf-8")
        @Assert(response_protocol,"http/1.1")
        @Assert(responseStr,"Response{protocol=http/1.1, code=200, message=OK, url=${request.getUrl().toString()}}")

        @Assert(response_isSuccess,true)

    }
}