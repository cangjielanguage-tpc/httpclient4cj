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


@Test
public class okhttp_Response_005{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_Response_005(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("https://cn.bing.com/")
                                    .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello world"))
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()

    var response2 = response.getPrevResponse()
    var get = response2 is Option<okhttp.Response>
    println("response2 is Option<Response> ${get}")
    @Assert(get, true)   
    }
}