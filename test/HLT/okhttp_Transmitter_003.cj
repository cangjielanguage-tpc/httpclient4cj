// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

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
from std import collection.*
from std import sync.sleep

var port: UInt16 = 0
class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        println("--------------------------------intercept-----------------------------")
        
        var transmitter = chain.getTransmitter()
        let request: okhttp.Request = chain.getRequest()
        transmitter.prepareToConnect(request)
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        var response: okhttp.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: okhttp.ResponseBuilder = response.newBuilder().request(request)
        println("hasConnection:${transmitter.hasConnection()}")
        println("hasExchange:${transmitter.hasExchange()}")
        @Assert(transmitter.hasExchange(),true) 
        transmitter.exchangeDoneDueToException()
        println("hasConnection:${transmitter.hasConnection()}")
        println("hasExchange:${transmitter.hasExchange()}")
        @Assert(transmitter.hasExchange(),false) 
        func exception(): String{ "exception"}
        exception()
        println("--------------------------------intercept-----------------------------")
        return responseBuilder.build()
    }
}

@Test
public class okhttp_Transmitter_003 {

    func serve(){
        let hd = http.Route() 
        hd.handle("/1234567", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.header().add("Last-Modified", "Tue, 27 May 2014 02:35:47 GMT")
            rws.header().add("cache-control", "no-cache") 
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    
    @TestCase
    func okhttp_Transmitter_003(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let cache: Cache = Cache("./okhttp_CacheControl_004", 10 * 1024 * 1024)
        let client: OkHttpClient= OkHttpClient.builder().cache(cache).addNetworkInterceptor(MyInterceptor()).build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234567")
                                        .method("GET")
                                        .build()
        client.newCall(request).execute()
    }
}