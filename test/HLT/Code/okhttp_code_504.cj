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

@Test
public class okhtttp_code_504{
    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/d1234A+!", { rws: ResponseWriteStream, req: http.Request =>
            rws.writeStatusCode(504)
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket) 
    }

    @TestCase
    func okhtttp_code_504(): Unit {
            
        spawn {
            serve()
        }
    sleep(1000*1000*1000)

    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/d1234A+!")
                                    .method("GET")
                                    .build()
    let call = client.newCall(request)
    let response: okhttp.Response = call.execute()
    let code : Int64 = response.getCode() 

    @Assert(code, Int64(504))
    }

}

