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
      
        let body: okhttp.RequestBody = okhttp.RequestBody("HTML","".toUtf8Array())
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("GET",body:body)
                                        .build()
    
        var body_Type = request.getBody().getOrThrow().contentType()
        @Assert(body_Type, "HTML")
        
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(0))
        
        var str_body:Array<Byte> = Array<Byte>(0, item: 0)
        var body_get = request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "".toUtf8Array())

    }

}

