// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

from net import http.*
from std import io.*
from std import time.*
from std import socket.*
from encoding import url.*

var port: UInt16 = 8079
main() {
    spawn {
        serve()
    } 
    sleep(1000*1000*1000)

    let url: URL = URL.parse("http://10.100.90.109:${port}/index")

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(Duration.second(1000))
                                .build()
    let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
    body.get()

    let resBodyCt = body.contentType()
    let resBodyCl = body.contentLength()
    println(resBodyCt)
    println(resBodyCl)

    let head: http.Header = Header()
    head.add("content-type", "application/json") 
    head.add("content-type2", "application2/json")
    
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url(url)
                                    .method("GET")
                                    .body(body)
                                    .header(head)
                                    .cacheControl(cache)
                                    .build()
                                    
    let resHead = request.getHeader("content-type")
    let resCon = request.getCacheControl().getOrThrow().toString()

    let call = client.newCall(request)
    let response: okhttp.Response = call.execute()
    let responseB = String(toArray(response.getBody().getOrThrow().getSource().readToEnd()))
    let responseCache = response.getCacheControl().getOrThrow().toString()

    if(resBodyCt != "Media-Type" ||
       resBodyCl != 9 ||
       resHead != "application/json" ||
       resCon != "no-cache, no-store, max-age=1000, only-if-cached, no-transform, immutable" ||
       responseCache != "no-cache, no-store, max-age=0, s-maxage=0, private, public, must-revalidate, max-stale=0, min-fresh=0, only-if-cached, no-transform, immutable") {
        return -1
    }

    response.close()
    return 0
}

func serve(){
    let hd = http.Route()
    hd.handle("/index", { rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket) 
}