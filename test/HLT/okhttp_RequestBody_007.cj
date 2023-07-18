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
from std import fs.*

let arr = ByteArrayStream()
class RequestBodySink<: Sink {

    public func write(bytes: Array<Byte>): Unit {
        arr.write(bytes)
        return ()
    }
    public func flush(): Unit {
    }
    public func close(): Unit {
    }

}

@Test
public class okhttp_RequestBody_writeTo {

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_writeTo(): Unit {
        var body : RequestBodySink = RequestBodySink()
        let RealRequestBody = httpclient4cj.RealRequestBody.create(MediaType.get("application/json"),"hello".toUtf8Array())
        RealRequestBody.writeTo(body)
        //println(String.fromUtf8(arr.readToEnd()))
        @Assert(String.fromUtf8(arr.readToEnd()), "hello")
    }
}