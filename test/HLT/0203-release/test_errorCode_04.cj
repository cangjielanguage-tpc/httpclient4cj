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
    func okhttp_fromHttp2_002(): Unit {
        var flag=0
        try{
             var re=ErrorCode.fromHttp2(23).getOrThrow()
        }catch(e:Exception){
             flag=1
        }
        @Assert(flag,1)
    }
}