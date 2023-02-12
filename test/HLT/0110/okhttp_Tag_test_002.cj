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
public class okhttp_Tag_Test_002{
    var port: UInt16 = 0
    // 设置多个 tag 同步发送请求 在拦截器中使用tag
    @TestCase
    func okhttp_Tag_Test_010(): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)

        var tags = ["tag_test_01", "tag_test_02", "tag_test_03", "tag_test_04", "tag_test_05"]
        let request_01: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[0])
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .tag(tags[4])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let request_02: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[0])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_03: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[4])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let request_04: okhttp.Request = okhttp.Request.builder()
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()

        let myInterceptor = MyInterceptor()
        let client: OkHttpClient= OkHttpClient.builder().addInterceptor(myInterceptor).build()
        myInterceptor.setClient(client)

        client.newCall(request_01).enqueue(MyCallbacks())
        client.newCall(request_02).enqueue(MyCallbacks())
        client.newCall(request_03).enqueue(MyCallbacks())
        client.newCall(request_04).enqueue(MyCallbacks())
    }

    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
            sleep(3000*1000*1000)
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

    public func onResponse(call: Call,  response: okhttp.Response): Unit{
        println("success")
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
        for(i in run) {
            if (i.getRequest().getTag("tag_test_01").tag != "") {
                //i.cancel()
                println("拦截到标签tag_test_01")
            }

            if (i.getRequest().getTag("tag_test_05").tag != "") {
                println("拦截到标签tag_test_05")
            }
        }
        return chain.proceed(chain.getRequest())
    }
}

