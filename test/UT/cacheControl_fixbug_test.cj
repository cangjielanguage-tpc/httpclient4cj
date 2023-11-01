
package httpclient4cj
from net import http.* as http3.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import time.*
from std import socket.*
from std import sync.sleep

@Test
public class okhtttp_001{

    func serve(){
        var port: UInt16 = 50066
        let hd = http3.Route()
        server.distributor.register("/index", { rws: http3.ResponseWriteStream, req: http3.Request =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        let server = http3.Server(hd)
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhtttp_001(): Unit {
        var port: UInt16 = 50066
        spawn {
            serve()
        } 
        sleep(Duration.second)

        let url: URL = URL.parse("http://127.0.0.1:${port}/index")

        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(Duration.second*1000)
                                    .build()
        let body: httpclient4cj.RequestBody = httpclient4cj.RequestBody("Media-Type", "text/html")
        body.get()

        let resBodyCt = body.contentType()
        let resBodyCl = body.contentLength()
        println(resBodyCt)
        println(resBodyCl)

        let head: http3.Header = Header()
        head.add("content-type", "application/json") 
        head.add("content-type2", "application2/json")
        
        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .body(body)
                                        .header(head)
                                        .cacheControl(cache)
                                        .build()
                                        
        let resHead = request.getHeader("content-type")
        let resCon = request.getCacheControl().getOrThrow().toString()

        let call = client.newCall(request)
        let response: httpclient4cj.Response = call.execute()
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

