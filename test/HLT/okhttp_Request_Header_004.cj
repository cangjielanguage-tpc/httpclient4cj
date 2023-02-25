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
public class okhttp_Request_Header_004{

    @TestCase
    func okhttp_Request_Header_004(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1108/1234")
        let header: http.Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()

        @Assert(request.getHeader("content-type","aaa"),  "application/json")
    }

}

