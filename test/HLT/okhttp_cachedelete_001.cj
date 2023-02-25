// 3rd_party_lib:okhttp/build/okhttp

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import fs.*

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        println("-------------------------------is Network----------------------------")
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        var response: okhttp.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: okhttp.ResponseBuilder = response.newBuilder().request(request)
        responseBuilder.header("Date","Thu, 23 Feb 2023 16:23:49 GMT")
        func exception(): String{ "exception"}
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cachedelete_001 {


    var port: UInt16 = 1501
    var sev_cache_control = "max-age=20000"
    func serve(){
        let hd = http.Route() 
        hd.handle("/1234567", { rws: http.ResponseWriteStream, req: http.Request =>
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
    @Skip
    func okhttp_cachedelete_001(): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)

        let cachecontrol: CacheControl = CacheControl.builder()
                                    .maxAge(2000)
                                    .build()
        let cache: Cache = Cache("./okhttp_cachedelete_001", 10 * 1024 * 1024)
        let client: OkHttpClient= OkHttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET").cacheControl(cachecontrol)
                                        .build()
        let request2: okhttp.Request = okhttp.Request.builder()
                                        .url("https://publicobject.com/helloworld.txt")
                                        .method("GET").cacheControl(cachecontrol)
                                        .build()
        println("-------------------------------OKHttp-第一次请求----------------------------")
        var response: okhttp.Response = client.newCall(request).execute()
        var body = response.getBody().getOrThrow().getString()
        var response_heads: http.Header = response.getHeaders()
        
        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }

        var sOrN_cache : Bool = true
        match (client.getCache()) {
            case Some(md) => sOrN_cache = false
            case None => sOrN_cache = true
        }
        println("client.getCache() is None? ${sOrN_cache}")
        @Assert(sOrN_cache,false) 

        println("cache.getSize() = ${cache.getSize()}")
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("response.getCacheControl() = ${response.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"max-age=2000")  
        @Assert(response.getCacheControl().toString(),sev_cache_control) 
        println("response.getSentRequestAtMillis() = ${response.getSentRequestAtMillis()}")
        @Assert(response.getSentRequestAtMillis().toString()=="",false)
        println("response.getReceivedResponseAtMillis() = ${response.getReceivedResponseAtMillis()}") 
        @Assert(response.getReceivedResponseAtMillis().toString()=="",false)  
        println("response.getNetworkResponse() : ${response.getNetworkResponse()}")
        println("response.getCacheResponse() : ${response.getCacheResponse()}")
        @Assert(response.getCacheResponse().toString(),"None")
        sleep(1000*1000*1000)
       
        println("-------------------------------OKHttp-OKHttp-第二次请求----------------------------")
        var response2: okhttp.Response = client.newCall(request).execute()
        var response_heads2: http.Header = response2.getHeaders()
        for ((nm,vl) in response_heads2) {
            println(nm)
            println(vl)
        }
        var body2 = response2.getBody().getOrThrow().getString()

        var sOrN_cache2 : Bool = true
        match (client.getCache()) {
            case Some(md) => sOrN_cache2 = false
            case None => sOrN_cache2 = true
        }

        println("client2.getCache() is None? ${sOrN_cache2}")
        @Assert(sOrN_cache2,false)  
        var cache2 = client.getCache()
        println("cache2.getSize() = ${cache2.getOrThrow().getSize()}")
        println("request.getCacheControl() = ${request.getCacheControl()}")
        println("response2.getCacheControl() = ${response2.getCacheControl()}")
        @Assert(request.getCacheControl().toString(),"max-age=2000")  
        @Assert(response2.getCacheControl().toString(),sev_cache_control) 
        println("response2.getSentRequestAtMillis() = ${response2.getSentRequestAtMillis()}")
        @Assert(response2.getSentRequestAtMillis().toString()=="",false) 
        println("response2.getReceivedResponseAtMillis() = ${response2.getReceivedResponseAtMillis()}")
        @Assert(response2.getReceivedResponseAtMillis().toString()=="",false) 
        println("response2.getNetworkResponse() : ${response2.getNetworkResponse()}")
        println("response2.getCacheResponse() : ${response2.getCacheResponse()}")
        @Assert(response2.getNetworkResponse().toString(),"None")

        @Assert(body,body2)
        println("-------------------------------OKHttp-OKHttp-第三次请求-更换服务器---------------------------")
        var response_3: okhttp.Response = client.newCall(request2).execute()
        var body3 = response_3.getBody().getOrThrow().getString()

        println("response_3.getNetworkResponse() : ${response_3.getNetworkResponse()}")
        println("response_3.getCacheResponse() : ${response_3.getCacheResponse()}")

        println("-------------------------------OKHttp-OKHttp-第四次请求-同第三次服务器---------------------------")
        var response_4: okhttp.Response = client.newCall(request2).execute()
        var body4 = response_4.getBody().getOrThrow().getString()

        println("response_4.getNetworkResponse() : ${response_4.getNetworkResponse()}")
        println("response_4.getCacheResponse() : ${response_4.getCacheResponse()}")

        println("-------------------------------OKHttp-OKHttp-第五次请求-更换客户端对象 缓存对象---------------------------")
        let cache3: Cache = Cache("./okhttp_cachedelete_001", 10 * 1024 * 1024)
        let client2: OkHttpClient= OkHttpClient.builder().cache(cache3).addNetworkInterceptor(MyInterceptor()).build()
        
        var response_5: okhttp.Response = client2.newCall(request2).execute()
        var body5 = response_5.getBody().getOrThrow().getString()

        println("response_5.getNetworkResponse() : ${response_5.getNetworkResponse()}")
        println("response_5.getCacheResponse() : ${response_5.getCacheResponse()}")

        println("-------------------------------OKHttp-OKHttp-第六次请求-更换缓存文件夹---------------------------")
        let cache4: Cache = Cache("./okhttp_cachedelete_001_2", 10 * 1024 * 1024)
        let client3: OkHttpClient= OkHttpClient.builder().cache(cache4).addNetworkInterceptor(MyInterceptor()).build()
        
        var response_6: okhttp.Response = client3.newCall(request2).execute()
        var body6 = response_6.getBody().getOrThrow().getString()

        println("response_6.getNetworkResponse() : ${response_6.getNetworkResponse()}")
        println("response_6.getCacheResponse() : ${response_6.getCacheResponse()}")

        for (i in cache.urls())
        {
            println("cache.urls() : ${i.toString()}")
        }
        for (i in cache3.urls())
        {
            println("cache3.urls() : ${i.toString()}")
        }
        for (i in cache4.urls())
        {
            println("cache4.urls() : ${i.toString()}")
        }
        
        cache3.delete()
        println("-------------------------------cache3.delete()---------------------------")
        for (i in cache.urls())
        {
            println("cache.urls() : ${i.toString()}")
        }
        for (i in cache3.urls())
        {
            println("cache3.urls() : ${i.toString()}")
        }
        for (i in cache4.urls())
        {
            println("cache4.urls() : ${i.toString()}")
        }
    }
    // @TestCase
    // func okhttp_cachedelete_001(): Unit {
    //     spawn {
    //         serve()
    //     }
    //     sleep(1000*1000*1000)

    //     let cachecontrol: CacheControl = CacheControl.builder()
    //                                 .maxAge(2000)
    //                                 .build()
    //     let cache: Cache = Cache("./okhttp_cachedelete_001", 10 * 1024 * 1024)
    //     let client: OkHttpClient= OkHttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
    //     let request: okhttp.Request = okhttp.Request.builder()
    //                                     .url("http://127.0.0.1:${port}/1234567")
    //                                     .method("GET").cacheControl(cachecontrol)
    //                                     .build()
    //     println("-------------------------------OKHttp-第一次请求----------------------------")
    //     var response: okhttp.Response = client.newCall(request).execute()
    //     var body = response.getBody().getOrThrow().getString()
    //     var response_heads: http.Header = response.getHeaders()
        
    //     for ((nm,vl) in response_heads) {
    //         println(nm)
    //         println(vl)
    //     }
    //     sleep(1000*1000*1000)

    //     println("-------------------------------OKHttp-OKHttp-第五次请求-更换客户端对象 缓存对象---------------------------")
    //     let cache3: Cache = Cache("./okhttp_cachedelete_001", 10 * 1024 * 1024)
    //     let client2: OkHttpClient= OkHttpClient.builder().cache(cache3).addNetworkInterceptor(MyInterceptor()).build()
        

    //     for (i in cache.urls())
    //     {
    //         println("cache.urls() : ${i.toString()}")
    //     }
        
    //     cache3.delete()
    //     println("-------------------------------cache3.delete()---------------------------")
    //     for (i in cache.urls())
    //     {
    //         println("cache.urls() : ${i.toString()}")
    //     }
    // }
}