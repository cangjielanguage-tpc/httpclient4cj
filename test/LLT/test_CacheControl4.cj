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
    sleep(Duration.second)
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
