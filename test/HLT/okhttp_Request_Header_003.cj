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
public class okhttp_Request_Header_003{

    @TestCase
    func okhttp_Request_Header_003(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1107/1234")
        let header: http.Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()
        func exception(): String{ "exception"}
        println(request.getHeader("content-type1").getOrDefault(exception))
        @Assert(request.getHeader("content-type1").getOrDefault(exception),"exception")
    }

}

