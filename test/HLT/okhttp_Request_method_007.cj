// 3rd_party_lib:okhttp/build/okhttp


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
public class okhttp_Request_method_007{

    @TestCase
    func okhttp_Request_method_007(): Unit {
        let request: okhttp.Request = okhttp.Request.builder()
                                        .method("DELETE")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "DELETE")

    }

}

