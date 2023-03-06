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
public class okhttp_Request_method_004{

    @TestCase
    func okhttp_Request_method_004(): Unit {
        let body: okhttp.RequestBody = okhttp.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toUtf8Array())
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("HEAD")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "HEAD")

    }
    @TestCase
    func okhttp_Request_method_004_exception(): Unit {
        var exception = ""
        let body: okhttp.RequestBody = okhttp.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toUtf8Array())
        try{
            let request: okhttp.Request = okhttp.Request.builder()
                                            .method("HEAD",body:body)
                                            .build()
            var request_method = request.getMethod()
            
        } catch (e : Exception) {
            println("e.message = ${e.message}")
            exception = e.message
        }
        @Assert(exception.contains("method HEAD must not have a request body."), true)

    }
}

