// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// data_file:body.text
// data_file:image.png

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
from std import fs.*
from std import sync.sleep

@Test
public class okhttp_MediaType_test_006{
    var port: UInt16 = 0
    // 使用自定义的MediaType 附加图片、word 等格式文件
    @TestCase
    func okhttp_MediaType_MultipartBody_test_034(): Unit {
        serve()

        let body_image = RealRequestBody.create(MediaType.get("text/img"),File("./image.png",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("image", "image.png", body_image)
            .build()
        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        client.newCall(request).enqueue(MyCallbacks())
    }

    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            println("***---****")
            println(StringReader(httpContext.request.body).readToEnd())
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
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