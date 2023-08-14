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
from std import log.*
from std import collection.*


@Test
public class okhttp_readHttp2HeadersList_001{
    @TestCase
    func okhttp_readHttp2HeadersList_001(): Unit {
        var headers=Header()
        headers.add(":status","200")
        var resp=Http2ExchangeCodec.readHttp2HeadersList(headers,httpclient4cj.Protocol.HTTP_2).build()
        @Assert(resp.getProtocol().toString(),"h2")
    }
}