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

@Test
public class okhttp_Response_message_001{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
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
    func okhttp_Response_message_001(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)

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
    var response_Message = response.getMessage()
  
    @Assert(response_Message,"OK")

    }
}