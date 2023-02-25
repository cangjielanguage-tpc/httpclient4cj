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
public class okhttp_Request_url_001{

    @TestCase
    func okhttp_Request_url_001(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1111/1234")
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url(url)
                                        .build()
        var request_url = request.getUrl().toString()
        println(request_url)
        @Assert(request_url, "http://127.0.0.1:1111/1234")

    }

}

