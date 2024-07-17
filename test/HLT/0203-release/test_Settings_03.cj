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
//验证数值
@Test
public class okhttp_Settings_03{

    @TestCase
    func okhttp_isSet_001(): Unit {
         var s01=Settings()
         var s02=s01.setting(3,10)
         @Assert(s01.isSet(3),true)
         @Assert(s02.isSet(3),true)
    }
    @TestCase
    func okhttp_isSet_002(): Unit {
         var s01=Settings()
         var s02=s01.setting(3,Int64.Max)
         @Assert(s01.isSet(3),true)
         @Assert(s02.isSet(3),true)
    }
    @TestCase
    func okhttp_isSet_003(): Unit {
         var s01=Settings()
         @Assert(s01.isSet(3),false)
    }
}