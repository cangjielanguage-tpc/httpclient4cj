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
from std import sync.sleep

@Test
public class okhtttp_code_406{
    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/d1234A+!", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            rws.writeStatusCode(406)
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
    func okhtttp_code_406(): Unit {
            
        spawn {
            serve()
        }
    sleep(Duration.second)

    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/d1234A+!")
                                    .method("GET")
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    let code : Int64 = response.getCode() 

    @Assert(code, Int64(406))
    }

}

