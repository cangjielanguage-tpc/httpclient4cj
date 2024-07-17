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

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        println("-------------------------------is Network----------------------------")
        let request: httpclient4cj.Request = chain.getRequest()
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)
        func exception(): String{ "exception"}
        exception()
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cache_002 {

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build() 
        server.distributor.register("/1234567", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.header("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
            port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_cache_002(): Unit {
        serve()

        let client: HttpClient= HttpClient.builder()
                                        .cache(Option<Cache>.None)
                                        .addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .build()
        var response: httpclient4cj.Response = client.newCall(request).execute()
        response.getBody().getOrThrow().getString()
        response.getHeaders()
        
        var sOrN_cache : Bool = false
        match (client.getCache()) {
            case None => sOrN_cache = true
            case _ => sOrN_cache = false
        }

        println("client.getCache() is None? ${sOrN_cache}")
        @Assert(sOrN_cache,true)
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("response.getCacheControl() = ${response.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"")  
        @Assert(response.getCacheControl().toString(),"") 
    }
}