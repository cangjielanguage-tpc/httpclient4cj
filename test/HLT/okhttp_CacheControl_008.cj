// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.Route
from net import http.ResponseWriteStream
from net import http.Request
from net import http.Server
from net import http.Header
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
public class okhttp_CacheControl_008 {


    var port: UInt16 = 0
    func serve(){
        let hd = http.Route() 
        hd.handle("/1234567", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            req
            let resp = "Hello from /red".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", "max-age=3") 
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    
    @TestCase
    func okhttp_CacheControl_008(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let cache: Cache = Cache("./okhttp_CacheControl_008", 10 * 1024 * 1024)
        let client: HttpClient= HttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .build()
        println("-------------------------------OKHttp-第一次请求----------------------------")
        var response: httpclient4cj.Response = client.newCall(request).execute()
        response.getBody().getOrThrow().getString()
        var response_heads: http.Header = response.getHeaders()
        
        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }

        var sOrN_cache : Bool = true
        match (client.getCache()) {
            case None => sOrN_cache = true
            case _  => sOrN_cache = false
        }
        println("client.getCache() is None? ${sOrN_cache}")
        @Assert(sOrN_cache,false) 

        println("cache.getSize() = ${cache.getSize()}")

        println("request.getCacheControl() = ${request.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"")  
        println("response.getCacheControl() = ${response.getCacheControl()}")
        @Assert(response.getCacheControl().toString(),"max-age=3") 

        println("request.getCacheControl().noCache() = ${request.getCacheControl().noCache()}")
        @Assert(request.getCacheControl().noCache(),false)  
        println("request.getCacheControl().noStore() = ${request.getCacheControl().noStore()}")
        @Assert(request.getCacheControl().noStore(),false)  
        println("request.getCacheControl().maxAgeSeconds() = ${request.getCacheControl().maxAgeSeconds()}")
        @Assert(request.getCacheControl().maxAgeSeconds(),-1)  
        println("request.getCacheControl().maxStaleSeconds() = ${request.getCacheControl().maxStaleSeconds()}")
        @Assert(request.getCacheControl().maxStaleSeconds(),-1)  
        println("request.getCacheControl().minFreshSeconds() = ${request.getCacheControl().minFreshSeconds()}")
        @Assert(request.getCacheControl().minFreshSeconds(),-1)  
        println("request.getCacheControl().onlyIfCached() = ${request.getCacheControl().onlyIfCached()}")
        @Assert(request.getCacheControl().onlyIfCached(),false)  
        println("request.getCacheControl().noTransform() = ${request.getCacheControl().noTransform()}")
        @Assert(request.getCacheControl().noTransform(),false)  
        println("request.getCacheControl().immutable() = ${request.getCacheControl().immutable()}")
        @Assert(request.getCacheControl().immutable(),false) 

        println("response.getCacheControl().noCache() = ${response.getCacheControl().noCache()}")
        @Assert(response.getCacheControl().noCache(),false) 
        println("response.getCacheControl().maxAgeSeconds() = ${response.getCacheControl().maxAgeSeconds()}")
        @Assert(response.getCacheControl().maxAgeSeconds(),3) 
        println("response.getCacheControl().sMaxAgeSeconds() = ${response.getCacheControl().sMaxAgeSeconds()}")
        @Assert(response.getCacheControl().sMaxAgeSeconds(),-1) 
        println("response.getCacheControl().isPrivate() = ${response.getCacheControl().isPrivate()}")
        @Assert(response.getCacheControl().isPrivate(),false) 
        println("response.getCacheControl().isPublic() = ${response.getCacheControl().isPublic()}")
        @Assert(response.getCacheControl().isPublic(),false) 
        println("response.getCacheControl().mustRevalidate() = ${response.getCacheControl().mustRevalidate()}")
        @Assert(response.getCacheControl().mustRevalidate(),false) 
        println("response.getCacheControl().noTransform() = ${response.getCacheControl().noTransform()}")
        @Assert(response.getCacheControl().noTransform(),false) 

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
        var response_heads2: http.Header = response2.getHeaders()
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
        @Assert(request.getCacheControl().toString(),"")  
        println("response2.getCacheControl() = ${response2.getCacheControl()}")
        @Assert(response2.getCacheControl().toString(),"max-age=3") 

        println("request.getCacheControl().noCache() = ${request.getCacheControl().noCache()}")
        @Assert(request.getCacheControl().noCache(),false)  
        println("request.getCacheControl().noStore() = ${request.getCacheControl().noStore()}")
        @Assert(request.getCacheControl().noStore(),false)  
        println("request.getCacheControl().maxAgeSeconds() = ${request.getCacheControl().maxAgeSeconds()}")
        @Assert(request.getCacheControl().maxAgeSeconds(),-1)  
        println("request.getCacheControl().maxStaleSeconds() = ${request.getCacheControl().maxStaleSeconds()}")
        @Assert(request.getCacheControl().maxStaleSeconds(),-1)  
        println("request.getCacheControl().minFreshSeconds() = ${request.getCacheControl().minFreshSeconds()}")
        @Assert(request.getCacheControl().minFreshSeconds(),-1)  
        println("request.getCacheControl().onlyIfCached() = ${request.getCacheControl().onlyIfCached()}")
        @Assert(request.getCacheControl().onlyIfCached(),false)  
        println("request.getCacheControl().noTransform() = ${request.getCacheControl().noTransform()}")
        @Assert(request.getCacheControl().noTransform(),false)  
        println("request.getCacheControl().immutable() = ${request.getCacheControl().immutable()}")
        @Assert(request.getCacheControl().immutable(),false) 

        println("response2.getCacheControl().noCache() = ${response2.getCacheControl().noCache()}")
        @Assert(response2.getCacheControl().noCache(),false) 
        println("response2.getCacheControl().maxAgeSeconds() = ${response2.getCacheControl().maxAgeSeconds()}")
        @Assert(response2.getCacheControl().maxAgeSeconds(),3) 
        println("response2.getCacheControl().sMaxAgeSeconds() = ${response2.getCacheControl().sMaxAgeSeconds()}")
        @Assert(response2.getCacheControl().sMaxAgeSeconds(),-1) 
        println("response2.getCacheControl().isPrivate() = ${response2.getCacheControl().isPrivate()}")
        @Assert(response2.getCacheControl().isPrivate(),false) 
        println("response2.getCacheControl().isPublic() = ${response2.getCacheControl().isPublic()}")
        @Assert(response2.getCacheControl().isPublic(),false) 
        println("response2.getCacheControl().mustRevalidate() = ${response2.getCacheControl().mustRevalidate()}")
        @Assert(response2.getCacheControl().mustRevalidate(),false) 
        println("response2.getCacheControl().noTransform() = ${response2.getCacheControl().noTransform()}")
        @Assert(response2.getCacheControl().noTransform(),false) 

        println("response2.getSentRequestAtMillis() = ${response2.getSentRequestAtMillis()}")
        @Assert(response2.getSentRequestAtMillis().toString()=="",false) 
        println("response2.getReceivedResponseAtMillis() = ${response2.getReceivedResponseAtMillis()}")
        @Assert(response2.getReceivedResponseAtMillis().toString()=="",false) 
        println("response2.getNetworkResponse() : ${response2.getNetworkResponse()}")
        println("response2.getCacheResponse() : ${response2.getCacheResponse()}")
        @Assert(response2.getNetworkResponse().toString(),"None")
        println("response2.getCacheResponse().toString() :[${response2.getCacheResponse()}]")
        @Assert(response2.getCacheResponse().toString(),"Some(Response{protocol=http/1.1, code=200, message=OK, url=${request.getUrl().toString()}})")
    }
}