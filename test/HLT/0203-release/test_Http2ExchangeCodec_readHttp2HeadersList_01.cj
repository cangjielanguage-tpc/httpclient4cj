// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/build/http2

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
from http2 import buffer.*
from http2 import common.*
from http2 import frame.*
from http2 import hpack.*
from http2 import proto.*
from std import log.*
from std import collection.*


@Test
public class okhttp_Chain_001{
    static var check1:String = ""
    static var check2:String = ""
    static var check3:String = ""

    @TestCase
    func okhttp_Chain_001(): Unit {
        var headers=Header()
        headers.add(":status","200")
        var resp=Http2ExchangeCodec.readHttp2HeadersList(headers,Protocol.HTTP_2).build()
        @Assert(resp.getProtocol().toString(),"h2")
    }
}