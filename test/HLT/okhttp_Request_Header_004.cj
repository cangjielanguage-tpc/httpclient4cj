// 3rd_party_lib:httpclient4cj/build/httpclient4cj


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

@Test
public class okhttp_Request_Header_004{

    @TestCase
    func okhttp_Request_Header_004(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1108/1234")
        let header: Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()

        // @Assert(request.getHeader("content-type","aaa"),  "application/json")
        @Assert(request.getHeader("content-type","aaa"),  "application/json,application2/json")
    }

}

