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
from std import sync.sleep

@Test
public class okhttp_Response_001{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_Response_001(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    response.getRequest()
    var response_heads: http.Header = response.getHeaders()
    var response_protocol = response.getProtocol().toString()
    var response_code : Int64 = response.getCode()
    var response_isSuccess:Bool= response.isSuccess()
    var responseStr:String = response.toString()


    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    println("protocol = ${response_protocol}")
    println("code = ${response_code}")
    println("isSuccess = ${response_isSuccess}")

    @Assert(response_code,Int64(200))
    @Assert(response.getHeader("aaa").toString(),"None")
    @Assert(response.getHeader("bbb","123"),"123")
    @Assert(response.getHeader("Content-Length"),"15")
    @Assert(response.getHeader("Date").toString().contains("GMT"),true)
    @Assert(response.getHeader("Connection"),"keep-alive")
    @Assert(response.getHeader("Content-Type"),"text/plain; charset=utf-8")
    @Assert(response_protocol,"http/1.1")
    @Assert(responseStr,"Response{protocol=http/1.1, code=200, message=OK, url=${request.getUrl().toString()}}")

    @Assert(response_isSuccess,true)

    }
}