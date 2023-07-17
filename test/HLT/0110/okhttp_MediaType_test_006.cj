// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj
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
        spawn {
            serve()
        }
        sleep(Duration.second)

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
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            println("***---****")
            //println(String.fromUtf8(req.readToEnd()))
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