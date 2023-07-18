// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj
// data_file:body.text

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
public class okhttp_MediaType_test_005{
    var port: UInt16 = 0
    // 使用和 MediaType 不相符的数据类型 创建MultipartBody -- 都是使用string 类型进行传输,类型不符合不影响内容的传递
    @TestCase
    func okhttp_MediaType_MultipartBody_test_033(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let body = RealRequestBody.create(MediaType.get("text/img"),File("./body.text",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("body", "body.text", body)
            .build()
        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        let response: httpclient4cj.Response = client.newCall(request).execute()
        println(response.toString())
        // 当前服务端返回的参数都为 text/plain; charset=utf-8
        let responseType = response.getBody().getOrThrow().getContentType() 
        match (responseType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Expect(get_type, "text")
                @Expect(get_sub, "plain")
                @Expect(get_charset, "utf-8")
            case None => 
                println("None")
        }
    }

    func serve() {
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
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

