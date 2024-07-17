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
public class okhttp_StatusLine_001{

    @TestCase
    func okhttp_StatusLine_001(): Unit {

        var stl = StatusLine.parse("HTTP/1.1 200 OK")
        
        @Assert(stl.protocol.toString(),httpclient4cj.Protocol.HTTP_1_1.toString())
        @Assert(stl.code,Int64(200))
        @Assert(stl.message,"OK")

        println("stl.toSting() : ${stl.toString()}")
        @Assert(stl.toString(),"HTTP/1.1 200 OK")
        
    }
}