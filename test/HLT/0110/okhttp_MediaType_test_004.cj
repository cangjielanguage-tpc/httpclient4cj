// 3rd_party_lib:okhttp/build/okhttp
// data_file:body.text

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
public class okhttp_MediaType_test_004{
    var port: UInt16 = 0
    // 创建 MultipartBody
    @TestCase
    func okhttp_MediaType_MultipartBody_test_032(): Unit {
        spawn {
            serve()
        }
        sleep(1000*1000*1000)

        let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("file", "body.text", body)
            .build()
        let client: OkHttpClient= OkHttpClient.builder().build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        let response: okhttp.Response = client.newCall(request).execute()
        println(response.toString())
        let responseType = response.getBody().getOrThrow().getContentType() // 如何修改服务端的返回类型呢?????
        match (responseType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Expect(get_type, "")
                @Expect(get_sub, "")
                @Expect(get_charset, "")
            case None => 
                println("None")
        }
    }

    func serve() {
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            println("***---****")
            println(String.fromUtf8(req.readToEnd()))
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }
}

