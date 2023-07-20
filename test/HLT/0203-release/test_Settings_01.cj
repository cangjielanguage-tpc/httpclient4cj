// 3rd_party_lib:httpclient4cj/build/httpclient4cj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
//验证功能
@Test
public class okhttp_Settings_01{
    @TestCase
    func okhttp_settings_001(): Unit {
         var s01=Settings()
         var s02=s01.setting(1,10)
         @Assert(s01.get(1),10)
         @Assert(s02.get(1),10)
    }

    @TestCase
    func okhttp_settings_002(): Unit {
         var s01=Settings()
         var s02=s01.setting(1,10)
         var s03=s01.setting(1,20)
         @Assert(s01.get(1),20)
         @Assert(s02.get(1),20)
         @Assert(s03.get(1),20)
    }
    @TestCase
    func okhttp_settings_003(): Unit {
         var s01=Settings()
         var s02=s01.setting(1,10)
         var s03=s02.setting(2,20)
         var s04=s03.setting(4,40)
         var s05=s04.setting(5,50)
         var s06=s05.setting(6,60)
         var s07=s06.setting(7,70)
         @Assert(s01.get(1),10)
         @Assert(s01.get(2),20)
         @Assert(s01.get(4),40)
         @Assert(s01.get(5),50)
         @Assert(s01.get(6),60)
         @Assert(s01.get(7),70)
    }
}