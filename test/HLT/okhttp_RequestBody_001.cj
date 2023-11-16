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
public class okhttp_RequestBody_001{

    @TestCase
    func okhttp_RequestBody_001(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello world"))
                                        .build()
    
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        println("body_Type = ${body_Type}")
        @Assert(body_Type, "application/json; charset=utf-8")
        
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(11))
        
        var str_body:Array<Byte> = Array<Byte>(11, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello world".toArray())

    }

}

