// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import fs.*
var port: UInt16 = 1504
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
//第一次走网络不使用缓存，第二次缓存不走网络(此时应该只生成tmp文件,cache只保存在内存中)
main() {
            spawn {
                serve()
            }
            sleep(1000*1000*1000)

            let cachecontrol: CacheControl = CacheControl.builder()
                                        .maxAge(2000)
                                        .build()
            let cache: Cache = Cache("./cc", 10 * 1024 * 1024)
            let client: OkHttpClient= OkHttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
            let request: okhttp.Request = okhttp.Request.builder()
                                            .url("http://127.0.0.1:${port}/1234567")
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
            sleep(1000*1000*1000)

            println("-------------------------------OKHttp-OKHttp-第五次请求-更换客户端对象 缓存对象---------------------------")
            let cache3: Cache = Cache("./cc", 10 * 1024 * 1024)
            let client2: OkHttpClient= OkHttpClient.builder().cache(cache3).addNetworkInterceptor(MyInterceptor()).build()


            for (i in cache.urls())
            {
                println("cache.urls() : ${i.toString()}")
            }
            try{
                cache3.delete()
            }catch(e:IllegalStateException){
                println(e.message)
            }
            println("-------------------------------cache3.delete()---------------------------")
            for (i in cache.urls())
            {
                println("cache.urls() : ${i.toString()}")
            }
            0
}

