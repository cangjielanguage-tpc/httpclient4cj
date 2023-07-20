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
from std import sync.sleep

@Test
public class okhtttp_code_411{
    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/d1234A+!", { httpContext =>
            httpContext.responseBuilder.status(411)
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhtttp_code_411(): Unit {
        serve()

    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/d1234A+!")
                                    .method("GET")
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    let code : Int64 = response.getCode() 

    @Assert(code, Int64(411))
    }

}

