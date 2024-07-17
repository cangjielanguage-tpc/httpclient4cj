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
public class okhttp_okhttpClient_002 {

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
    func okhttp_okhttpClient_002 (): Unit {
        serve()
        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(1000)
                                    .build()
        let client: HttpClient= HttpClient.builder()
                                                // .tlsConfig("")//../data/jjd.cer
                                                .followSslRedirects(false)
                                                .authenticator({_: ?httpclient4cj.Route, _: httpclient4cj.Response => Option<httpclient4cj.Request>.None})
                                                .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("GET")
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        call.execute()

        // println(client.getTlsConfig().getOrThrow().certificateChainFile)
        // @Assert(client.getTlsConfig().getOrThrow().certificateChainFile, "")
        // println(client.getTlsConfig().getOrThrow().caFile)
        // @Assert(client.getTlsConfig().getOrThrow().caFile, "")//../data/jjd.cer
        println(client.getFollowSslRedirects())
        @Assert(client.getFollowSslRedirects(), false)
        
    }
}
