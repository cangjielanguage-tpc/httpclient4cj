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
public class okhttp_Response_002{

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/12345", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_Response_002(): Unit {
    serve()

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: HttpClient= HttpClient.builder().build()
    // let body: httpclient4cj.RequestBody = httpclient4cj.RequestBody("Media-Type", "text/html")
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
    response.toString()


    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    println("protocol = ${response_protocol}")
    println("code = ${response_code}")
    println("isSuccess = ${response_isSuccess}")
    
    //@Assert(request2,request)
    @Assert(response_code,Int64(404))
    // @Assert(str, "404 page not found")
    // @Assert(response_body, "404 page not found".toArray())
    @Assert(response_isSuccess,false)

    }
}