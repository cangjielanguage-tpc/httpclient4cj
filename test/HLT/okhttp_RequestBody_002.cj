// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/http2

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
public class okhttp_RequestBody_002{

    @TestCase
    func okhttp_RequestBody_002(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),""))
                                        .build()
    
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        println("body_Type = ${body_Type}")
        @Assert(body_Type, "application/json; charset=utf-8")
        
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(0))
        
        var str_body:Array<Byte> = Array<Byte>(0, item: 0)
        var body_get = request.getBody().getOrThrow().get().read(str_body)
        println("body_get = [${body_get}]")
        println("str_body = [${String.fromUtf8(str_body)}]")
        @Assert(str_body, "".toUtf8Array())

    }

}

