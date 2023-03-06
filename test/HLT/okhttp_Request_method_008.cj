// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj


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
public class okhttp_Request_method_008{

    @TestCase
    func okhttp_Request_method_008(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("CONNECT")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "CONNECT")

    }
    @TestCase
    func okhttp_Request_method_008_body(): Unit {
        let body: okhttp.RequestBody = okhttp.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toUtf8Array())
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("CONNECT",body:body)
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "CONNECT")

        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toUtf8Array())

    }

}

