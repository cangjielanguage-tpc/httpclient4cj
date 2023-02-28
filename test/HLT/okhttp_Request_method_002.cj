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
public class okhttp_Request_url_002{

    @TestCase
    func okhttp_Request_url_002(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("PUT",body: RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello world"))
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "PUT")

    }

}

