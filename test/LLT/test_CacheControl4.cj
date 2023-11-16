// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
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
from std import sync.sleep

var port: UInt16 = 1504
var sev_cache_control = "max-age=200"
func serve() {
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register(
        "/1",
        {
            httpContext =>
            let resp = "Hello from 1".toArray()
            httpContext.responseBuilder.header("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            httpContext.responseBuilder.header("cache-control", sev_cache_control)
            httpContext.responseBuilder.body(resp)
            return
        }
    )
    server.distributor.register(
        "/2",
        {
            httpContext =>
            let resp = "Hello from 2".toArray()
            httpContext.responseBuilder.header("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            httpContext.responseBuilder.header("cache-control", sev_cache_control)
            httpContext.responseBuilder.body(resp)
            return
        }
    )
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}
main() {
    serve()
    let cache: Cache = Cache("./okhttp_cache_001", 10 * 1024 * 1024)
    let client: HttpClient = HttpClient.builder().cache(cache).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/1").method("GET").build()
    
    try{
        let cache1: Cache = Cache("./okhttp_cache_001", 10 * 1024 * 1024)
        // let client1: HttpClient = HttpClient.builder().cache(cache1).build()
        // let request1: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/2").method("GET").build()
        // let res1 = client1.newCall(request1).execute().getBody().getOrThrow().getString()
        // println(res1)
    }catch(e:IllegalStateException){
        println(e.message)
    }
    
    let res = client.newCall(request).execute().getBody().getOrThrow().getString()
    println(res)

    cache.delete()

    for(i in cache.urls()){
        println(i)
    }

    return 0
}
