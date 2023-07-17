// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj

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

@Test
public class okhttp_Tag_Test_002{
    var port: UInt16 = 0
    // 设置多个 tag 同步发送请求 在拦截器中使用tag
    @TestCase
    func okhttp_Tag_Test_010(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        var tags = ["tag_test_01", "tag_test_02", "tag_test_03", "tag_test_04", "tag_test_05"]
        let request_01: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[0])
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .tag(tags[4])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let request_02: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[0])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_03: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[4])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_04: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let myInterceptor = MyInterceptor()
        let client: HttpClient= HttpClient.builder().addInterceptor(myInterceptor).build()
        myInterceptor.setClient(client)

        let response_01: httpclient4cj.Response = client.newCall(request_01).execute()
        @Assert(response_01.getHeader("tag_test_01"),"tag_test_01")
        @Assert(response_01.getHeader("tag_test_05"),"tag_test_05")
        let response_02: httpclient4cj.Response = client.newCall(request_02).execute()
        @Assert(response_02.getHeader("tag_test_01"),"tag_test_01")
        let response_03: httpclient4cj.Response = client.newCall(request_03).execute()
        @Assert(response_03.getHeader("tag_test_05"),"tag_test_05")
        let response_04: httpclient4cj.Response = client.newCall(request_04).execute()
        @Assert(response_04.getHeader("tag_test_05").toString(), "None")

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

public class MyCallbacks <: Callback {
    public func onFailure(call: Call,  e: Exception): Unit{
        println("${e.message}")
    }

    public func onResponse(call: Call,  response: httpclient4cj.Response): Unit{
        println("success")
    }
}


class MyInterceptor<: Interceptor {
    var client: Option<HttpClient> = Option<HttpClient>.None
    public func setClient(client: HttpClient) {
        this.client = client
    }

    public func intercept(chain: Chain): httpclient4cj.Response {
        let dispatcher = client.getOrThrow().getDispatcher()
        let run = dispatcher.runningCalls()
        println(run.size)

        let request: httpclient4cj.Request = chain.getRequest()
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)

        for(i in run) {
            if (i.getRequest().getTag("tag_test_01").tag != "") {
                responseBuilder.header("tag_test_01","tag_test_01")
                println("拦截到标签tag_test_01")
            }

            if (i.getRequest().getTag("tag_test_05").tag != "") {
                responseBuilder.header("tag_test_05","tag_test_05")
                println("拦截到标签tag_test_05")
            }
        }
        return responseBuilder.build()
    }
}

