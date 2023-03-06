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
public class okhttp_okhttpClient_002 {

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
    func okhttp_okhttpClient_002 (): Unit {
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
                                                .followSslRedirects(false)
                                                .authenticator({route: Option<okhttp.Route>, response: okhttp.Response => Option<okhttp.Request>.None})
                                                .build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("GET")
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        var response: okhttp.Response = call.execute()

        println(client.getTlsConfig().getOrThrow().certificateChainFile)
        println(client.getTlsConfig().getOrThrow().caFile)
        println(client.getFollowSslRedirects())

        
    }
}
