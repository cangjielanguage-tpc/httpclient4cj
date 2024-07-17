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
    func okhttp_fromHttp2_001(): Unit {
        @Assert(ErrorCode.fromHttp2(0).getOrThrow().toString(),"NO_ERROR")
        @Assert(ErrorCode.fromHttp2(1).getOrThrow().toString(),"PROTOCOL_ERROR")
        @Assert(ErrorCode.fromHttp2(2).getOrThrow().toString(),"INTERNAL_ERROR")
        @Assert(ErrorCode.fromHttp2(3).getOrThrow().toString(),"FLOW_CONTROL_ERROR")
        @Assert(ErrorCode.fromHttp2(7).getOrThrow().toString(),"REFUSED_STREAM")
        @Assert(ErrorCode.fromHttp2(8).getOrThrow().toString(),"CANCEL")
        @Assert(ErrorCode.fromHttp2(9).getOrThrow().toString(),"COMPRESSION_ERROR")
        @Assert(ErrorCode.fromHttp2(10).getOrThrow().toString(),"CONNECT_ERROR")
        @Assert(ErrorCode.fromHttp2(11).getOrThrow().toString(),"ENHANCE_YOUR_CALM")
        @Assert(ErrorCode.fromHttp2(12).getOrThrow().toString(),"INADEQUATE_SECURITY")
        @Assert(ErrorCode.fromHttp2(13).getOrThrow().toString(),"HTTP_1_1_REQUIRED")
    }
}