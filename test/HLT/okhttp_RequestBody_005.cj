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
public class okhttp_RequestBody_005{

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_005(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello".toUtf8Array()))
                                        .build()
        // test contentType
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        @Assert(body_Type, "application/json; charset=utf-8")
        // test getContentLength
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(5))
        //test get
        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        var body_get = request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toUtf8Array())

    }

}

