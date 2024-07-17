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
public class okhttp_okhttpClient_003{

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
    func okhttp_okhttpClient_003 (): Unit {
        serve()
        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(1000)
                                    .build()
        let client: HttpClient= HttpClient.builder()
                                                // .tlsConfig("")//../data/jjd.cer
                                                .followSslRedirects(true)
                                                .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("GET")
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        call.execute()

        println("client.getInterceptors().size:${client.getInterceptors().size}")
        @Assert(client.getInterceptors().size,0)
        println("client.getNetworkInterceptors().size:${client.getNetworkInterceptors().size}")
        @Assert(client.getNetworkInterceptors().size,0)
        println("client.getConnectTimeout():${client.getConnectTimeout()}")
        @Assert(client.getConnectTimeout().toString(),"Some(10s)")
        println("client.getReadTimeout():${client.getReadTimeout()}")
        @Assert(client.getReadTimeout().toString(),"Some(10s)")
        println("client.getWriteTimeout():${client.getWriteTimeout()}")
        @Assert(client.getWriteTimeout().toString(),"Some(10s)")
        println("client.getProtocols():${client.getProtocols()}")
        @Assert(client.getProtocols().toString(),"[http/1.1]")
        client.getEventListener()        
    }
}
