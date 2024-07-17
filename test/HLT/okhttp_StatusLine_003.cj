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
public class okhttp_StatusLine_003 {

    @TestCase
    func okhttp_StatusLine_003(): Unit {
        var exc = ""
        try{
            StatusLine.parse("HTTP/1.1200 OK")
        } catch (e:Exception) {
            exc = e.message
        }
        
        @Assert(exc.contains("Unexpected status line"),true)      
    }
}