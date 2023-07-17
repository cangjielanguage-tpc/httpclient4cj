// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj

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

@Test
public class okhttp_RequestBody_006{

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_006(): Unit {
        println(Directory(".").info.path)
        
        var file: File = File("../../RealRequestBody.html",OpenOption.Open(true,true))
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json"),file))
                                        .build()
        // test contentType
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        @Assert(body_Type, "application/json")
        // test getContentLength
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(5))
        //test get
        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toUtf8Array())

    }

}

