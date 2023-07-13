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
public class okhttp_Tag_Test_004{
    var port: UInt16 = 0
    // 设置多个 tag 异步发送请求 在拦截器中使用tag 查看接收是否是异步(接收端打印的sun.size 每次都是1 是异步)
    @TestCase
    func okhttp_Tag_Test_012(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        var tags = ["tag_test_01", "tag_test_02", "tag_test_03", "tag_test_04", "tag_test_05"]
        let request_01: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[0])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let request_02: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[1])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_03: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[2])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_04: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[3])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let request_05: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[4])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let myInterceptor = MyInterceptor()
        let client: OkHttpClient= OkHttpClient.builder().addInterceptor(myInterceptor).build()
        myInterceptor.setClient(client)

        try{
            let response_01: okhttp.Response = client.newCall(request_01).execute()
            @Assert(response_01.getHeader("tag_test_01"),"tag_test_01")
            let response_02: okhttp.Response = client.newCall(request_02).execute()
            @Assert(response_02.getHeader("tag_test_02"),"tag_test_02")
            let response_03: okhttp.Response = client.newCall(request_03).execute()
            @Assert(response_03.getHeader("tag_test_03"),"tag_test_03")
            let response_04: okhttp.Response = client.newCall(request_04).execute()
            @Assert(response_04.getHeader("tag_test_04"),"tag_test_04")
            let response_05: okhttp.Response = client.newCall(request_05).execute()
            @Assert(response_05.getHeader("tag_test_05"),"tag_test_05")
        }catch (e: Exception) {
            println("${e.message}")
        }
    }

    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            sleep(Duration.second)
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

}

class MyInterceptor<: Interceptor {
    var client: Option<OkHttpClient> = Option<OkHttpClient>.None
    public func setClient(client: OkHttpClient) {
        this.client = client
    }

    public func intercept(chain: Chain): okhttp.Response {
        let dispatcher = client.getOrThrow().getDispatcher()
        let run = dispatcher.runningCalls()
        println(run.size)
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
        var response: okhttp.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: okhttp.ResponseBuilder = response.newBuilder().request(request)
        for(i in run) {
            if (i.getRequest().getTag("tag_test_01").tag != "") {
                responseBuilder.header("tag_test_01","tag_test_01")
                println("拦截到标签tag_test_01")
            }

            if (i.getRequest().getTag("tag_test_02").tag != "") {
                responseBuilder.header("tag_test_02","tag_test_02")
                println("拦截到标签tag_test_02")
            }

            if (i.getRequest().getTag("tag_test_03").tag != "") {
                responseBuilder.header("tag_test_03","tag_test_03")
                println("拦截到标签tag_test_03")
            }

            if (i.getRequest().getTag("tag_test_04").tag != "") {
                responseBuilder.header("tag_test_04","tag_test_04")
                println("拦截到标签tag_test_04")
            }

            if (i.getRequest().getTag("tag_test_05").tag != "") {
                responseBuilder.header("tag_test_05","tag_test_05")
                println("拦截到标签tag_test_05")
            }
        }
        return responseBuilder.build()
    }
}

