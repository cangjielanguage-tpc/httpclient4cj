// 3rd_party_lib:httpclient4cj/build/httpclient4cj

import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*

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