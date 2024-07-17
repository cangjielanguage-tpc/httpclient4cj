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
import std.math.*

@Test
public class okhttp_Settings_07{
    @TestCase
    func okhttp_getMaxConcurrentStreams_001(): Unit {
         var s01=Settings()
         @Assert(s01.getMaxConcurrentStreams(30),30)
    }
    @TestCase
    func okhttp_getMaxConcurrentStreams_002(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(2,20)
         s01.setting(4,40)
         s01.setting(5,50)
         s01.setting(6,60)
         s01.setting(7,70)
         @Assert(s01.getMaxConcurrentStreams(30),40)
    }
}