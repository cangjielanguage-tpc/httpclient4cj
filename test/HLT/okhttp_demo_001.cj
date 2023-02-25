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
public class okhttp_demo{

    var port: UInt16 = 1103
    func serve(){
        let hd = http.Route()
        hd.handle("/1235", { rws: http.ResponseWriteStream, req: http.Request =>
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
    func okhttp_demo(): Unit {
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
                                    .url("http://127.0.0.1:${port}/1235")
                                    .method("GET")//加body
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    var response_heads: http.Header = response.getHeaders()
    // var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
    // var str =String.fromUtf8(response_body)
    var response_protocol = response.getProtocol().toString()
    var response_code : Int64 = response.getCode()
    var response_isSuccess:Bool= response.isSuccess()

    println("-------------------------------OKHttp-Response_Header----------------------------")
    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    println("protocol = ${response_protocol}")
    println("code = ${response_code}")
    println("isSuccess = ${response_isSuccess}")
    
    @Assert(response_code,Int64(200))
    // @Assert(str, "Hello from /red")
    // @Assert(response_body, "Hello from /red".toUtf8Array())
    @Assert(response.getHeader("Content-Length").getOrThrow(),"15")
    @Assert(response.getHeader("Date").getOrThrow().contains("GMT"),true)
    @Assert(response.getHeader("Connection").getOrThrow(),"keep-alive")
    @Assert(response.getHeader("Content-Type").getOrThrow(),"text/plain; charset=utf-8")
    @Assert(response_protocol,"http/1.1")

    //@Assert(response_isSuccess,true)

    }
}

@Test
public class http_demo{

    var port: UInt16 = 1104
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
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
    func http_demo(): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)
        let client = Client()
        var a: http.Response = client.get("http://127.0.0.1:${port}/1234")
        var byteStream = ByteArrayStream()
        a.copyTo(byteStream)
        var str = String.fromUtf8(a.readToEnd())
        var str_Response = String.fromUtf8(byteStream.readToEnd())

        println("------------------------------------Http-Response--------------------------------")
        println(str_Response)
     
        //println("http.Response.body")
        //println(str)
        @Assert(str, "Hello from /red")
        //@Assert(str, "404 page not found")
    }
}