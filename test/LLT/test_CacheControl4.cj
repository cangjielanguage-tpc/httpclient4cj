// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
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

var port: UInt16 = 1504
var sev_cache_control = "max-age=200"
func serve() {
    let hd = http.Route()
    hd.handle(
        "/1",
        {
            rws: http.ResponseWriteStream, req: http.Request =>
            let resp = "Hello from 1".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", sev_cache_control)
            rws.write(resp)
            return
        }
    )
    hd.handle(
        "/2",
        {
            rws: http.ResponseWriteStream, req: http.Request =>
            let resp = "Hello from 2".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", sev_cache_control)
            rws.write(resp)
            return
        }
    )
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}
main() {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let cache: Cache = Cache("./okhttp_cache_001", 10 * 1024 * 1024)
    let client: OkHttpClient = OkHttpClient.builder().cache(cache).build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/1").method("GET").build()
    
    let cache1: Cache = Cache("./okhttp_cache_001", 10 * 1024 * 1024)
    // let client1: OkHttpClient = OkHttpClient.builder().cache(cache1).build()
    // let request1: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/2").method("GET").build()

    let res = client.newCall(request).execute().getBody().getOrThrow().getString()
    println(res)
    // let res1 = client1.newCall(request1).execute().getBody().getOrThrow().getString()
    // println(res1)

    // cache.delete()
    try{
        cache1.delete()
    }catch(e:IllegalStateException){
        println(e.message)
    }

    for(i in cache.urls()){
        println(i)
    }
    cache.delete()
    for(i in cache1.urls()){
        println(i)
    }

    return 0
}
