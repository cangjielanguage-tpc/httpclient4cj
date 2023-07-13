// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


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

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)
        func exception(): String{ "exception"}
        exception()
        return responseBuilder.build()
    }
}

@Test
public class okhttp_cache_003 {

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route() 
        hd.handle("/1234567", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", "max-age=1000") 
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    
    @TestCase
    func okhttp_cache_003(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let client: HttpClient= HttpClient.builder()
                                        .addNetworkInterceptor(MyInterceptor()).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .build()
        var response: httpclient4cj.Response = client.newCall(request).execute()
        response.getBody().getOrThrow().getString()
        response.getHeaders()
        
        var sOrN_cache : Bool = false
        match (client.getCache()) {
            case None => sOrN_cache = true
            case _ => sOrN_cache = false
        }

        println("client.getCache() is None? ${sOrN_cache}")
        @Assert(sOrN_cache,true)  
    }
}