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


@Test
public class okhttp_StatusLine_002{

    @TestCase
    func okhttp_StatusLine_002(): Unit {

        var stl = StatusLine(Protocol.HTTP_1_1,Int64(200),"OK")
        
        @Assert(stl.protocol.toString(),Protocol.HTTP_1_1.toString())
        @Assert(stl.code,Int64(200))
        @Assert(stl.message,"OK")

        println("stl.toSting() : ${stl.toString()}")
        @Assert(stl.toString(),"HTTP/1.1 200 OK")
        
    }
}