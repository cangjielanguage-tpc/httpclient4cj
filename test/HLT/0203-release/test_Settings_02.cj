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
public class okhttp_Settings_02{

    @TestCase
    func okhttp_settings_001(): Unit {
         var s01=Settings()
         var s02=s01.setting(3,10)
         @Assert(s01.get(3),10)
         @Assert(s02.get(3),10)
    }
    @TestCase
    func okhttp_settings_002(): Unit {
         var s01=Settings()
         var s02=s01.setting(1,Int64.Max)
         @Assert(s01.get(1),Int64.Max)
         @Assert(s02.get(1),Int64.Max)
    }
    @TestCase
    func okhttp_settings_003(): Unit {
         var s01=Settings()
         var s02=s01.setting(7,Int64.Min)
         @Assert(s01.get(7),Int64.Min)
         @Assert(s02.get(7),Int64.Min)
    }
}