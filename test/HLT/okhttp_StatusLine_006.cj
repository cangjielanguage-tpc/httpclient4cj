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
public class okhttp_StatusLine_006 {

    @TestCase
    func okhttp_StatusLine_006(): Unit {
        var exc = ""
        var stl = StatusLine.parse("HTTP/1.1 200")
        try{
            stl = StatusLine.parse("HTTP/1.1 200")
        } catch (e:Exception) {
            e.printStackTrace()
            exc = e.message
        }
        @Assert(exc,"")  
        println("stl.toSting() : ${stl.toString()}")
        @Assert(stl.toString(),"HTTP/1.1 200")    
    }
}