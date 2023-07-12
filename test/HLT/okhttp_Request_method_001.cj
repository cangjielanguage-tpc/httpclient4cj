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
public class okhttp_Request_method_001{

    @TestCase
    func okhttp_Request_method_001(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("GET")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "GET")

    }
    @TestCase
    func okhttp_Request_method_001_exception(): Unit {
        var exception = ""
        let body: okhttp.RequestBody = okhttp.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toUtf8Array())
        try{
            let request: okhttp.Request = okhttp.Request.builder()
                                            .method("GET",body:body)
                                            .build()
            request.getMethod()
            
        } catch (e : Exception) {
            println("e.message = ${e.message}")
            exception = e.message
        }
        @Assert(exception.contains("method GET must not have a request body."), true)

    }

}

