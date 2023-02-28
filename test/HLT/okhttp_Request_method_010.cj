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
from std import fs.*

@Test
public class okhttp_Request_method_010{


    var port: UInt16 = 1110
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
    func okhttp_Request_method_010(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("abc")
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()

    print("log flush", flush:true)
    sleep(1000*1000*1000*1)
    var filename = "../../log/split_log/HLT.okhttp_Request_method_010.cj.log"
    var bytearry = File.readFrom(filename)
    var str = String.fromUtf8(bytearry)

    @Assert(str.contains("net/http: invalid method:abc"), true)

    }
}


