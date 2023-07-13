// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj
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
public class okhttp_MediaType_test_004{
    var port: UInt16 = 0
    // 创建 MultipartBody
    @TestCase
    func okhttp_MediaType_MultipartBody_test_032(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("file", "body.text", body)
            .build()
        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        let response: httpclient4cj.Response = client.newCall(request).execute()
        println(response.toString())
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

