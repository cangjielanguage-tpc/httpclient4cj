
package okhttp
from net import http.* as http3.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import time.*
from std import socket.*

@Test
public class okhtttp_001{

    func serve(){
        var port: UInt16 = 50066
        let hd = http3.Route()
        hd.handle("/index", { rws: http3.ResponseWriteStream, req: http3.Request =>
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http3.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket) 
    }

    @TestCase
    func okhtttp_001(): Unit {
        var port: UInt16 = 50066
        spawn {
            serve()
        } 
        sleep(1000*1000*1000)

        let url: URL = URL.parse("http://127.0.0.1:${port}/index")

        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(Duration.second(1000))
                                    .build()
        let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
        body.get()

        let resBodyCt = body.contentType()
        let resBodyCl = body.contentLength()
        println(resBodyCt)
        println(resBodyCl)

        let head: http3.Header = Header()
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
        let responseCache = response.getCacheControl().getOrThrow().toString()
        var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
        var str = String.fromUtf8(response_body)

        @Assert(resBodyCt, "Media-Type")
        @Assert(resBodyCl, 9)
        @Assert(resHead, "application/json")
        
        @Assert(resCon, "no-cache, no-store, max-age=1000, only-if-cached, no-transform, immutable")
        @Assert(responseCache, "no-cache, no-store, max-age=0, s-maxage=0, private, public, must-revalidate, max-stale=0, min-fresh=0, only-if-cached, no-transform, immutable") 
        @Assert(str,"Hello from /red")
        response.close()
    }
}

