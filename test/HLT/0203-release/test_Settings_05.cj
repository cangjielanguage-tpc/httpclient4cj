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
public class okhttp_Settings_05{
    @TestCase
    func okhttp_size_001(): Unit {
         var s01=Settings()
         @Assert(s01.size(),0)
    }
    @TestCase
    func okhttp_size_002(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(2,20)
         s01.setting(4,40)
         s01.setting(5,50)
         s01.setting(6,60)
         s01.setting(7,70)
         @Assert(s01.size(),6)
    }
    @TestCase
    func okhttp_size_003(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(3,10)
         s01.setting(2,20)
         s01.setting(4,40)
         s01.setting(5,50)
         s01.setting(6,60)
         s01.setting(7,70)
         @Assert(s01.size(),7)
    }
    @TestCase
    func okhttp_size_004(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(1,20)
         @Assert(s01.size(),1)
    }
}