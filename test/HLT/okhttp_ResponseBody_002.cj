// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/http2

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


@Test
public class okhttp_ResponseBody_002{

    var port: UInt16 = 8888
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
    @Skip
    func okhttp_ResponseBody_002(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(Duration.second(1000))
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .body(body)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    var response_heads: http.Header = response.getHeaders()
    var response_body:Array<Byte> = Array<Byte>(0, item: 0)
    //response.getBody().getOrThrow()//.getSource().read(response_body)
        match(response.getBody()) {
        case Some(a) =>
            return println("body")
                
        case None =>
            return println("None")
        }
    //var str =String.fromUtf8(response_body)
    println("response_body")
    //println(str)
    
    //@Assert(str, "")
    @Assert(response_body, "".toUtf8Array())


    }
}