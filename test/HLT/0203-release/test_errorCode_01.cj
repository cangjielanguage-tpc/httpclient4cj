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
public class okhttp_errorCode_01{
    @TestCase
    func okhttp_errorCode_toString_001(): Unit {
        @Assert(ErrorCode.NO_ERROR.toString(),"NO_ERROR")
        @Assert(ErrorCode.PROTOCOL_ERROR.toString(),"PROTOCOL_ERROR")
        @Assert(ErrorCode.INTERNAL_ERROR.toString(),"INTERNAL_ERROR")
        @Assert(ErrorCode.FLOW_CONTROL_ERROR.toString(),"FLOW_CONTROL_ERROR")
        @Assert(ErrorCode.REFUSED_STREAM.toString(),"REFUSED_STREAM")
        @Assert(ErrorCode.CANCEL.toString(),"CANCEL")
        @Assert(ErrorCode.COMPRESSION_ERROR.toString(),"COMPRESSION_ERROR")
        @Assert(ErrorCode.CONNECT_ERROR.toString(),"CONNECT_ERROR")
        @Assert(ErrorCode.ENHANCE_YOUR_CALM.toString(),"ENHANCE_YOUR_CALM")
        @Assert(ErrorCode.INADEQUATE_SECURITY.toString(),"INADEQUATE_SECURITY")
        @Assert(ErrorCode.HTTP_1_1_REQUIRED.toString(),"HTTP_1_1_REQUIRED")
    }
}