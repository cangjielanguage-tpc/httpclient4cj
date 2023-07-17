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
public class okhttp_StatusLine_007 {

    @TestCase
    func okhttp_StatusLine_007(): Unit {
        var exc = ""
        try{
            StatusLine.parse("200 OK")
        } catch (e:Exception) {
            exc = e.message
        }
        @Assert(exc.contains("Unexpected status line"),true)      
    }
}