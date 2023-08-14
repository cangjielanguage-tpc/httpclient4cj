// 3rd_party_lib:httpclient4cj/build/httpclient4cj
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
from std import collection.*
from std import fs.*
from std import sync.sleep

@Test
public class okhttp_EventListener_test_001{
    init(){ serve() }
    var port: UInt16 = 0
    // 验证 EventListener 方法调用
    @TestCase
    func okhttp_EventListener_test_001(): Unit {
        let request_01: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let client: HttpClient= HttpClient.builder().eventListener(MyEventListener()).build()
        client.newCall(request_01).enqueue(MyCallbacks())
    }
    
    @TestCase
    func okhttp_EventListener_test_002(): Unit {
        let request_01: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("https://1.0.0.1:${port}/1234")
                                        .build()
        let client: HttpClient= HttpClient.builder().eventListener(MyEventListener()).build()
        client.newCall(request_01).enqueue(MyCallbacks())
    }

    @TestCase
    func okhttp_EventListener_test_003(): Unit {
        let body_image = RealRequestBody.create(MediaType.get("text/img"),File("./image.png",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("image", "image.png", body_image)
            .build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        let client: HttpClient= HttpClient.builder().eventListener(MyEventListener()).build()
        let response = client.newCall(request).enqueue(MyCallbacks())
    }

    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
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

public class MyEventListener <: EventListener {
    public func callStart(call: Call): Unit {
        println("MyEventListener: callStart()")
    }

    public func callEnd(call: Call): Unit {
        println("MyEventListener: callEnd()")
    }

    public func dnsStart(call: Call, domainName: String): Unit {
        println("MyEventListener: dnsStart()")
    }

    public func dnsEnd(call: Call, domainName: String, allRoutes: ArrayList<httpclient4cj.Route>): Unit {
        println("MyEventListener: dnsEnd()")
    }

    public func connectStart(call: Call, socketAddress: SocketAddress): Unit {
        println("MyEventListener: connectStart()")
    }

    public func connectEnd(call: Call, socketAddress: SocketAddress, protocol: httpclient4cj.Protocol): Unit {
        println("MyEventListener: connectEnd()")
    }

    public func secureConnectStart(call: Call): Unit {
        println("MyEventListener: secureConnectStart()")
    }

    public func secureConnectEnd(call: Call, tlsConfig: TlsClientConfig): Unit {
        println("MyEventListener: secureConnectEnd()")
    }

    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: httpclient4cj.Protocol, e: httpclient4cj.HttpException ): Unit {
        println("MyEventListener: connectFailed()")
    }

    public func requestHeadersStart(call: Call): Unit {
        println("MyEventListener: requestHeadersStart()")
    }

    public func requestHeadersEnd(call: Call): Unit {
        println("MyEventListener: requestHeadersEnd()")
    }

    public func requestBodyStart(call: Call): Unit {
        println("MyEventListener: requestBodyStart()")
    }

    public func requestBodyEnd(call: Call, byteCount: Int64): Unit {
        println("MyEventListener: requestBodyEnd()")
    }

    public func requestFailed(call: Call, e: httpclient4cj.HttpException): Unit {
        println("MyEventListener: requestFailed()")
    }

    public func responseHeadersStart(call: Call): Unit {
        println("MyEventListener: responseHeadersStart()")
    }

    public func responseHeadersEnd(call: Call, response: httpclient4cj.Response): Unit {
        println("MyEventListener: responseHeadersEnd()")
    }

    public func responseBodyStart(call: Call): Unit {
        println("MyEventListener: responseBodyStart()")
    }

    public func responseBodyEnd(call: Call, byteCount: Int64): Unit {
        println("MyEventListener: responseBodyEnd()")
    }

    public func responseFailed(call: Call, e: httpclient4cj.HttpException): Unit {
        println("MyEventListener: responseFailed()")
    }
}