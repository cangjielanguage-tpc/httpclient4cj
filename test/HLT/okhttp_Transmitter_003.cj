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
import std.collection.*
import std.sync.sleep

var port: UInt16 = 0
class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        println("--------------------------------intercept-----------------------------")
        
        var transmitter = chain.getTransmitter()
        let request: httpclient4cj.Request = chain.getRequest()
        transmitter.prepareToConnect(request)
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)
        println("hasConnection:${transmitter.hasConnection()}")
        println("hasExchange:${transmitter.hasExchange()}")
        @Assert(transmitter.hasExchange(),true) 
        transmitter.exchangeDoneDueToException()
        println("hasConnection:${transmitter.hasConnection()}")
        println("hasExchange:${transmitter.hasExchange()}")
        @Assert(transmitter.hasExchange(),false) 
        func exception(): String{ "exception"}
        exception()
        println("--------------------------------intercept-----------------------------")
        return responseBuilder.build()
    }
}

@Test
public class okhttp_Transmitter_003 {

    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build() 
        server.distributor.register("/1234567", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.header("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            httpContext.responseBuilder.header("cache-control", "no-cache") 
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    
    @TestCase
    func okhttp_Transmitter_003(): Unit {
        serve()

        let cache: Cache = Cache("./okhttp_CacheControl_004", 10 * 1024 * 1024)
        let client: HttpClient= HttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .build()
        client.newCall(request).execute()
    }
}