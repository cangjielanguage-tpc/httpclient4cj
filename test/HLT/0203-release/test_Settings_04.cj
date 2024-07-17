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
public class okhttp_Settings_04{
    @TestCase
    func okhttp_get_001(): Unit {
         var s01=Settings()
         var re=s01.get(3)
         @Assert(re,0)
    }
    @TestCase
    func okhttp_get_002(): Unit {
         var s01=Settings()
         var re=s01.get(1)
         @Assert(re,0)
    }
    @TestCase
    func okhttp_get_003(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         var re=s01.get(1)
         @Assert(re,10)
    }
}