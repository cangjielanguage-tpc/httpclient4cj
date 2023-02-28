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
public class okhttp_StatusLine_006 {

    @TestCase
    func okhttp_StatusLine_006(): Unit {
        var exc = ""
        var stl = StatusLine.parse("HTTP/1.1 200")
        try{
            stl = StatusLine.parse("HTTP/1.1 200")
        } catch (e:Exception) {
            e.printStackTrace()
            exc = e.message
        }
        @Assert(exc,"")  
        println("stl.toSting() : ${stl.toString()}")
        @Assert(stl.toString(),"HTTP/1.1 200")    
    }
}