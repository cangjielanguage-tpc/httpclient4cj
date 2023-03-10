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

@Test
public class okhttp_okhttpClient_003{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
            let resp = "hello".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_okhttpClient_003 (): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)
        var exe = ""
        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(1000)
                                    .build()
        let client: OkHttpClient= OkHttpClient.builder()
                                                .tlsConfig("../data/jjd.cer")
                                                .followSslRedirects(true)
                                                .build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("GET")
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        var response: okhttp.Response = call.execute()

        println("client.getInterceptors().size:${client.getInterceptors().size}")
        @Assert(client.getInterceptors().size,0)
        println("client.getNetworkInterceptors().size:${client.getNetworkInterceptors().size}")
        @Assert(client.getNetworkInterceptors().size,0)
        println("client.getConnectTimeout():${client.getConnectTimeout()}")
        @Assert(client.getConnectTimeout().toString(),"Some(10s)")
        println("client.getReadTimeout():${client.getReadTimeout()}")
        @Assert(client.getReadTimeout().toString(),"Some(10s)")
        println("client.getWriteTimeout():${client.getWriteTimeout()}")
        @Assert(client.getWriteTimeout().toString(),"Some(10s)")
        println("client.getProtocols():${client.getProtocols()}")
        @Assert(client.getProtocols().toString(),"[http/1.1]")
        client.getEventListener()        
    }
}
