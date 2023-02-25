// 3rd_party_lib:okhttp/build/okhttp


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
public class okhttp_Response_002{

    var port: UInt16 = 1113
    func serve(){
        let hd = http.Route()
        hd.handle("/12345", { rws: http.ResponseWriteStream, req: http.Request =>
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
    func okhttp_Response_002(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    // let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    var request2: okhttp.Request = response.getRequest()
    var response_heads: http.Header = response.getHeaders()
    // var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
    // var str =String.fromUtf8(response_body)
    var response_protocol = response.getProtocol().toString()
    var response_code : Int64 = response.getCode()
    var response_isSuccess:Bool= response.isSuccess()
    var responseStr = response.toString()
    // println("response_body")
    // println(str)

    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    println("protocol = ${response_protocol}")
    println("code = ${response_code}")
    println("isSuccess = ${response_isSuccess}")
    
    //@Assert(request2,request)
    @Assert(response_code,Int64(404))
    // @Assert(str, "404 page not found")
    // @Assert(response_body, "404 page not found".toUtf8Array())
    @Assert(response_isSuccess,false)

    }
}