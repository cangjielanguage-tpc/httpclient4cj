// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// data_file:body.text

from encoding import url.*
from net import http.*
from net import tls.*
from httpclient4cj import httpclient4cj.*
from std import fs.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import socket.*
from std import sync.sleep
from std import time.*

@Test
public class okhttp_MediaType_test_004{
    var port: UInt16 = 0
    // 创建 MultipartBody
    @TestCase
    func okhttp_MediaType_MultipartBody_test_032(): Unit {
        serve()

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

