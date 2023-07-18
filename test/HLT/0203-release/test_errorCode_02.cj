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
public class okhttp_errorCode_01{
    @TestCase
    func okhttp_errorCode_getCode_002(): Unit {
        @Assert(ErrorCode.NO_ERROR.getCode(),0)
        @Assert(ErrorCode.PROTOCOL_ERROR.getCode(),1)
        @Assert(ErrorCode.INTERNAL_ERROR.getCode(),2)
        @Assert(ErrorCode.FLOW_CONTROL_ERROR.getCode(),3)
        @Assert(ErrorCode.REFUSED_STREAM.getCode(),7)
        @Assert(ErrorCode.CANCEL.getCode(),8)
        @Assert(ErrorCode.COMPRESSION_ERROR.getCode(),9)
        @Assert(ErrorCode.CONNECT_ERROR.getCode(),10)
        @Assert(ErrorCode.ENHANCE_YOUR_CALM.getCode(),11)
        @Assert(ErrorCode.INADEQUATE_SECURITY.getCode(),12)
        @Assert(ErrorCode.HTTP_1_1_REQUIRED.getCode(),13)
    }
}