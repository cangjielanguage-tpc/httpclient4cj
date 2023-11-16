// 3rd_party_lib:httpclient4cj/build/httpclient4cj

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
from std import fs.*
from std import sync.sleep

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        println("-------------------------------is Network----------------------------")
        let request: httpclient4cj.Request = chain.getRequest()
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)
        func exception(): String{ "exception"}
        exception()
        let utctime = DateTime.nowUTC()
        let utctimestr = utctime.toString(", dd MMM yyyy HH:mm:ss z")
        let str = "${utctime.dayOfWeek.toString()[0..3]}${utctimestr}"
        println("str:${str}")
        responseBuilder.header("Date",str)
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cache_001 {


    var port: UInt16 = 0
    var sev_cache_control = "max-age=200"
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build() 
        server.distributor.register("/1234567", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.header("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            httpContext.responseBuilder.header("cache-control", sev_cache_control) 
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }
   
    @TestCase
    func okhttp_cache_001(): Unit {
        serve()
        let cachecontrol: CacheControl = CacheControl.builder()
                                    .maxAge(20)
                                    .build()
        let cache: Cache = Cache("./okhttp_cache_001", 10 * 1024 * 1024)
        let client: HttpClient= HttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET").cacheControl(cachecontrol)
                                        .build()
        println("-------------------------------OKHttp-第一次请求----------------------------")
        var response: httpclient4cj.Response = client.newCall(request).execute()
        response.getBody().getOrThrow().getString()
        var response_heads: Header = response.getHeaders()
        
        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }

        var sOrN_cache : Bool = true
        match (client.getCache()) {
            case None => sOrN_cache = true
            case _ => sOrN_cache = false
        }
        println("client.getCache() is None? ${sOrN_cache}")
        @Assert(sOrN_cache,false) 

        println("cache.getSize() = ${cache.getSize()}")
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("response.getCacheControl() = ${response.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"max-age=20")  
        @Assert(response.getCacheControl().toString(),sev_cache_control) 
        println("response.getSentRequestAtMillis() = ${response.getSentRequestAtMillis()}")
        @Assert(response.getSentRequestAtMillis().toString()=="",false)
        println("response.getReceivedResponseAtMillis() = ${response.getReceivedResponseAtMillis()}") 
        @Assert(response.getReceivedResponseAtMillis().toString()=="",false)  
        println("response.getNetworkResponse() : ${response.getNetworkResponse()}")
        println("response.getCacheResponse() : ${response.getCacheResponse()}")
        @Assert(response.getCacheResponse().toString(),"None")
        sleep(Duration.second)
       
        println("-------------------------------OKHttp-OKHttp-第二次请求----------------------------")
        var response2: httpclient4cj.Response = client.newCall(request).execute()
        var response_heads2: Header = response2.getHeaders()
        for ((nm,vl) in response_heads2) {
            println(nm)
            println(vl)
        }
        response2.getBody().getOrThrow().getString()

        var sOrN_cache2 : Bool = true
        match (client.getCache()) {
            case None => sOrN_cache2 = true
            case _ => sOrN_cache2 = false
        }

        println("client2.getCache() is None? ${sOrN_cache2}")
        @Assert(sOrN_cache2,false)  
        var cache2 = client.getCache()
        println("cache2.getSize() = ${cache2.getOrThrow().getSize()}")
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("response2.getCacheControl() = ${response2.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"max-age=20")  
        @Assert(response2.getCacheControl().toString(),sev_cache_control) 
        println("response2.getSentRequestAtMillis() = ${response2.getSentRequestAtMillis()}")
        @Assert(response2.getSentRequestAtMillis().toString()=="",false) 
        println("response2.getReceivedResponseAtMillis() = ${response2.getReceivedResponseAtMillis()}")
        @Assert(response2.getReceivedResponseAtMillis().toString()=="",false) 
        println("response2.getNetworkResponse() : ${response2.getNetworkResponse()}")
        println("response2.getCacheResponse() : ${response2.getCacheResponse()}")
        @Assert(response2.getNetworkResponse().toString(),"None")
    }
}