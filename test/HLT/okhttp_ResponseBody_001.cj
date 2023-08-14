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
public class okhttp_ResponseBody_001{

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_ResponseBody_001(): Unit {
    serve()

    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello world"))
                                    .build()
    var call = client.newCall(request)
    var response: httpclient4cj.Response = call.execute()
    var responsebody = response.getBody().getOrThrow().getString()
    println("responsebody = ${responsebody}")

    @Assert(responsebody, "Hello from /red")


    }
}