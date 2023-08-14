// 3rd_party_lib:httpclient4cj/build/httpclient4cj


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

@Test
public class okhttp_Request_method_006{

    @TestCase
    func okhttp_Request_method_006(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("TRACE")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "TRACE")

    }
    @TestCase
    func okhttp_Request_method_006_body(): Unit {
        let body: httpclient4cj.RequestBody = httpclient4cj.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toUtf8Array())
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("TRACE",body:body)
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "TRACE")

        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toUtf8Array())
    }
}

