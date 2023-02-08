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
from std import math.*
from http2 import buffer.*
from http2 import common.*
from http2 import frame.*
from http2 import hpack.*
from http2 import proto.*

class subSink <: Sink{
    public init(){}
    public func write(bytes: Array<Byte>){}
    public func flush(){}
    public func close(){}
}
@Test
public class okhttp_H2Stream_01{
    @TestCase
    func okhttp_close_001(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>()
        rb.write(bs)
        rb.close()
    }
    @TestCase
    func okhttp_close_002(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>(10000,item:9)
        rb.write(bs)
        rb.flush()
        rb.close()
    }
    @TestCase
    func okhttp_close_003(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>(10000,item:9)
        rb.write(bs)
        rb.flush()
        rb.write(bs)
        rb.close()
        var flag=0
        try{
            rb.flush()
        }catch(e:Exception){
            if(e.toString().contains("closed")==true){
                flag=1
            }
        }
        @Assert(flag,1)
    }
}