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
import std.core.*
import std.sync.sleep

@Test
public class okhttp_ResponseBody_007{

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "hello".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_ResponseBody_007(): Unit {
        serve()
        var exe = ""
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

        println("isClosed =${response.getBody().getOrThrow().isClosed()}")
        @Assert(response.getBody().getOrThrow().isClosed(), false)
        response.getBody().getOrThrow().close()
        println("isClosed =${response.getBody().getOrThrow().isClosed()}")
        @Assert(response.getBody().getOrThrow().isClosed(), true)

        try{
            var response_body = response.getBody().getOrThrow().getString()
            var response_bodyContentLength  = response.getBody().getOrThrow().getContentLength()
            var response_bodyContentType : String  = response.getBody().getOrThrow().getContentType().toString()
        
            println("response_body =${response_body}")
            println("response_bodyContentType =${response_bodyContentType}")
            @Assert(response_body, "hello")
            @Assert(response_bodyContentLength, Int64(5))
            @Assert(response_bodyContentType, "text/plain; charset=utf-8")
        } catch (e:Exception){
            println("e.message = ${e.message}")
            exe = e.message
        }
        @Assert(exe.contains("closed"), true)
    }
}