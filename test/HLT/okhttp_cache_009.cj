// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj

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
        // func exception(): String{ "exception"}
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cache_009 {

    var port: UInt16 = 0
    var sev_cache_control = "max-age=200"
    func serve(){
        let hd = http.Route() 
        hd.handle("/1234567", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            req
            let resp = "Hello from /red".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", sev_cache_control) 
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }
   
    @TestCase
    func okhttp_cache_009(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let cachecontrol: CacheControl = CacheControl.builder()
                                    .maxAge(20)
                                    .build()
        let cache: Cache = Cache("./okhttp_cache_009", 10 * 1024 * 1024)
        let client: HttpClient= HttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello world")).cacheControl(cachecontrol)
                                        .build()
        println("-------------------------------OKHttp-第一次请求----------------------------")
        var response: httpclient4cj.Response = client.newCall(request).execute()
        response.getBody().getOrThrow().getString()
        var response_heads: http.Header = response.getHeaders()
        
        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }

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
        let request2: httpclient4cj.Request = httpclient4cj.Request.builder()
                                .url("http://127.0.0.1:${port}/1234567")
                                .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello")).cacheControl(cachecontrol)
                                .build()
        var response2: httpclient4cj.Response = client.newCall(request2).execute()
        var response_heads2: http.Header = response2.getHeaders()
        for ((nm,vl) in response_heads2) {
            println(nm)
            println(vl)
        }
        response2.getBody().getOrThrow().getString()
        println("request2.getCacheControl() = ${request2.getCacheControl()}")
        println("response2.getCacheControl() = ${request2.getCacheControl()}")
        @Assert(request2.getCacheControl().toString(),"max-age=20")  
        @Assert(response2.getCacheControl().toString(),sev_cache_control) 
        println("response2.getSentRequestAtMillis() = ${response2.getSentRequestAtMillis()}")
        @Assert(response2.getSentRequestAtMillis().toString()=="",false) 
        println("response2.getReceivedResponseAtMillis() = ${response2.getReceivedResponseAtMillis()}")
        @Assert(response2.getReceivedResponseAtMillis().toString()=="",false) 
        println("response2.getNetworkResponse() : ${response2.getNetworkResponse()}")
        println("response2.getCacheResponse() : ${response2.getCacheResponse()}")
        @Assert(response2.getCacheResponse().toString(),"None")
    }
}