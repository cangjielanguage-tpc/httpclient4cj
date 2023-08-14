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
public class okhttp_ResponseBody_005{


    @TestCase //ResponseBody.init() ContentLength = ResponseBody长度
    func okhttp_ResponseBody_005(): Unit {
        let arr = ByteArrayStream()
        arr.write("hello".toUtf8Array())
        var inputStream: InputStream = arr
        var source :OkBuffer = OkBuffer(inputStream)
        var response_body : ResponseBody = ResponseBody("text/plain; charset=utf-8",5,source)

        var str = response_body.getString()
        println("response_body =${str}")

        @Assert(str, "hello")

    }
}