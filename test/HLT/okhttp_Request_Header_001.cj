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
public class okhttp_Request_Header_001{

    @TestCase
    func okhttp_Request_Header_001(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1105/1234")
        let header: http.Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type2", "application2/json")
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()
        @Assert(request.getHeader("content-type").getOrThrow(), "application/json")
        @Assert(request.getHeader("content-type2").getOrThrow(), "application2/json")
    }

}

