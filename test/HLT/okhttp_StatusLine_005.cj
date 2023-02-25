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
public class okhttp_StatusLine_005 {

    @TestCase
    func okhttp_StatusLine_005(): Unit {
        var exc = ""
        try{
            var stl = StatusLine.parse("HTTP/1.1 OK")
        } catch (e:Exception) {
            exc = e.message
        }
        @Assert(exc.contains("Unexpected status line"),true)      
    }
}