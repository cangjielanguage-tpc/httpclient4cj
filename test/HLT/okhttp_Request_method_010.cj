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
public class okhttp_Request_method_010{


    var port: UInt16 = 8888
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
    func okhtttp_demo(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    var exc = ""
    try {
        let client: OkHttpClient= OkHttpClient.builder().build()
        //let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("abc")
                                        //.body(body)
                                        .build()
        var call = client.newCall(request)
        var response: okhttp.Response = call.execute()

    } catch(e: Exception) {
        exc = e.getMessage()
    }
    println(exc)
    @Assert(exc, "no such method")

    }
}


