// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj

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

@Test // ResponseBody.getString  ""
public class okhttp_ResponseBody_004{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_ResponseBody_004(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)

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
    response.getHeaders()   
    var response_body = response.getBody().getOrThrow().getString()
    var response_bodyContentLength  = response.getBody().getOrThrow().getContentLength()
    var response_bodyContentType : String  = response.getBody().getOrThrow().getContentType().getOrThrow().toString()
    
    println("response_body =${response_body}")
    println("response_bodyContentType =${response_bodyContentType}")
    @Assert(response_body, "")
    @Assert(response_bodyContentLength, Int64(0))
    @Assert(response_bodyContentType, "text/plain; charset=utf-8")

    }
}