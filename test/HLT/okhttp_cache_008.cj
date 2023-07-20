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
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cache_008 {

    var port: UInt16 = 0
    var sev_cache_control = "max-age=200"
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder.new().listener(serverSocket).build() 
        server.distributor.register("/1234567", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
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
    @Skip
    func okhttp_cache_008(): Unit {
        serve()

        let cachecontrol: CacheControl = CacheControl.builder()
                                    .maxAge(20)
                                    .build()
        let cache: Cache = Cache("./okhttp_cache_008", 10 * 1024 * 1024)
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

        println("request.getMethod() = ${request.getMethod()}")
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("request.getm() = ${request.getCacheControl()}")
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
        let cachecontrol2: CacheControl = CacheControl.builder()
                                    .maxAge(2)
                                    .build()
        let header: Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request2: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .header(header)
                                        .cacheControl(cachecontrol2)
                                        .build()
        var response2: httpclient4cj.Response = client.newCall(request2).execute()

        println("-------------------------------OKHttp-OKHttp-第二次请求--request2--------------------------")
        var request_heads2: Header = request2.getHeaders()
        for ((nm,vl) in request_heads2) {
            println(nm)
            println(vl)
        }
        println("-------------------------------OKHttp-OKHttp-第二次请求--response2--------------------------")
        var response_heads2: Header = response2.getHeaders()
        for ((nm,vl) in response_heads2) {
            println(nm)
            println(vl)
        }
        response2.getBody().getOrThrow().getString()
        println("request2.getMethod() = ${request2.getMethod()}")
        println("request2.getCacheControl() = ${request2.getCacheControl()}")

        println("response2.getCacheControl() = ${response2.getCacheControl()}")
        // @Assert(request2.getCacheControl().toString(),"max-age=30")  
        @Assert(response2.getCacheControl().toString(),sev_cache_control) 
        println("response2.getSentRequestAtMillis() = ${response2.getSentRequestAtMillis()}")
        @Assert(response2.getSentRequestAtMillis().toString()=="",false) 
        println("response2.getReceivedResponseAtMillis() = ${response2.getReceivedResponseAtMillis()}")
        @Assert(response2.getReceivedResponseAtMillis().toString()=="",false) 
        println("response2.getNetworkResponse() : ${response2.getNetworkResponse()}")
        println("response2.getCacheResponse() : ${response2.getCacheResponse()}")
        @Assert(response2.getCacheResponse().toString(),"Some(Response{protocol=http/1.1, code=200, message=OK, url=${request2.getUrl().toString()}})")
    }
}