// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.sync.sleep

@Test
public class okhtttp_code_206{
    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/d1234A+!", { httpContext =>
            httpContext.responseBuilder.status(206)
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhtttp_code_206(): Unit {
        serve()

    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/d1234A+!")
                                    .method("GET")
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    let code : Int64 = response.getCode() 

    @Assert(code, Int64(206))
    }

}

