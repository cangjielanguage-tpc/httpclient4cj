// 3rd_party_lib:httpclient4cj/build/httpclient4cj
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
        serve()

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
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toArray()
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

