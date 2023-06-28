// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj
// data_file:image.png

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
from std import collection.*
from std import fs.*
from std import sync.sleep

@Test
public class okhttp_EventListener_test_001{
    var port: UInt16 = 0
    // 验证 EventListener 方法调用
    @TestCase
    func okhttp_EventListener_test_001(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)
        let request_01: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .build()
        let client: OkHttpClient= OkHttpClient.builder().eventListener(MyEventListener()).build()
        client.newCall(request_01).enqueue(MyCallbacks())
        sleep(10*Duration.second)
    }
    
    @TestCase
    func okhttp_EventListener_test_002(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)
        let request_01: okhttp.Request = okhttp.Request.builder()
                                        .url("https://1.0.0.1:${port}/1234")
                                        .build()
        let client: OkHttpClient= OkHttpClient.builder().eventListener(MyEventListener()).build()
        client.newCall(request_01).enqueue(MyCallbacks())
        sleep(10*Duration.second)
    }

    @TestCase
    func okhttp_EventListener_test_003(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)

        let body_image = RealRequestBody.create(MediaType.get("text/img"),File("./image.png",OpenOption.Open(true,false)))

        let multipartBody = MultipartBody.builder()
            .addFormDataPart("name", "aaa")
            .addFormDataPart("image", "image.png", body_image)
            .build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("POST", body: multipartBody)
                                        .build()
        let client: OkHttpClient= OkHttpClient.builder().eventListener(MyEventListener()).build()
        let response = client.newCall(request).enqueue(MyCallbacks())
        sleep(10*Duration.second)
    }

    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
            sleep(Duration.second)
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            println(String.fromUtf8(req.readToEnd()))
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

    public func dnsEnd(call: Call, domainName: String, allRoutes: ArrayList<okhttp.Route>): Unit {
        println("MyEventListener: dnsEnd()")
    }

    public func connectStart(call: Call, socketAddress: SocketAddress): Unit {
        println("MyEventListener: connectStart()")
    }

    public func connectEnd(call: Call, socketAddress: SocketAddress, protocol: Protocol): Unit {
        println("MyEventListener: connectEnd()")
    }

    public func secureConnectStart(call: Call): Unit {
        println("MyEventListener: secureConnectStart()")
    }

    public func secureConnectEnd(call: Call, tlsConfig: TlsClientConfig): Unit {
        println("MyEventListener: secureConnectEnd()")
    }

    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: okhttp.HttpException ): Unit {
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

    public func requestFailed(call: Call, e: okhttp.HttpException): Unit {
        println("MyEventListener: requestFailed()")
    }

    public func responseHeadersStart(call: Call): Unit {
        println("MyEventListener: responseHeadersStart()")
    }

    public func responseHeadersEnd(call: Call, response: okhttp.Response): Unit {
        println("MyEventListener: responseHeadersEnd()")
    }

    public func responseBodyStart(call: Call): Unit {
        println("MyEventListener: responseBodyStart()")
    }

    public func responseBodyEnd(call: Call, byteCount: Int64): Unit {
        println("MyEventListener: responseBodyEnd()")
    }

    public func responseFailed(call: Call, e: okhttp.HttpException): Unit {
        println("MyEventListener: responseFailed()")
    }
}