// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*


@Test // ResponseBody.getString  ""
public class okhttp_ResponseBody_004{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
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
    sleep(1000*1000*1000)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    var response_heads: http.Header = response.getHeaders()   
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