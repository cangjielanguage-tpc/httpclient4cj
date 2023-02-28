// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import math.*

@Test
public class okhttp_Settings_10{
    @TestCase
    func okhttp_merge_001(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(2,20)
         s01.setting(4,40)
         var s02=Settings()
         s02.setting(5,50)
         s02.setting(6,60)
         s02.setting(7,70)
         s01.merge(s02)
         @Assert(s01.get(1),10)
         @Assert(s01.get(2),20)
         @Assert(s01.get(4),40)
         @Assert(s01.get(5),50)
         @Assert(s01.get(6),60)
         @Assert(s01.get(7),70)
         @Assert(s02.get(1),0)
         @Assert(s02.get(2),0)
         @Assert(s02.get(4),0)
         @Assert(s02.get(5),50)
         @Assert(s02.get(6),60)
         @Assert(s02.get(7),70)
    }
    @TestCase
    func okhttp_merge_002(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(2,20)
         s01.setting(4,40)
         s01.setting(5,50)
         s01.setting(6,60)
         s01.setting(7,70)
         var s02=Settings()
         s01.merge(s02)
         @Assert(s01.get(1),10)
         @Assert(s01.get(2),20)
         @Assert(s01.get(4),40)
         @Assert(s01.get(5),50)
         @Assert(s01.get(6),60)
         @Assert(s01.get(7),70)
         @Assert(s02.get(1),0)
         @Assert(s02.get(2),0)
         @Assert(s02.get(4),0)
         @Assert(s02.get(5),0)
         @Assert(s02.get(6),0)
         @Assert(s02.get(7),0)
    }
    @TestCase
    func okhttp_merge_003(): Unit {
         var s01=Settings()
         var s02=Settings()
         s02.setting(1,10)
         s02.setting(2,20)
         s02.setting(4,40)
         s02.setting(5,50)
         s02.setting(6,60)
         s02.setting(7,70)
         s01.merge(s02)
         @Assert(s01.get(1),10)
         @Assert(s01.get(2),20)
         @Assert(s01.get(4),40)
         @Assert(s01.get(5),50)
         @Assert(s01.get(6),60)
         @Assert(s01.get(7),70)
         @Assert(s02.get(1),10)
         @Assert(s02.get(2),20)
         @Assert(s02.get(4),40)
         @Assert(s02.get(5),50)
         @Assert(s02.get(6),60)
         @Assert(s02.get(7),70)
    }
    @TestCase
    func okhttp_merge_004(): Unit {
         var s01=Settings()
         s01.setting(1,100)
         s01.setting(2,200)
         s01.setting(4,400)
         s01.setting(5,500)
         s01.setting(6,600)
         s01.setting(7,700)
         var s02=Settings()
         s02.setting(1,10)
         s02.setting(2,20)
         s02.setting(4,40)
         s02.setting(5,50)
         s02.setting(6,60)
         s02.setting(7,70)
         s01.merge(s02)
         @Assert(s01.get(1),10)
         @Assert(s01.get(2),20)
         @Assert(s01.get(4),40)
         @Assert(s01.get(5),50)
         @Assert(s01.get(6),60)
         @Assert(s01.get(7),70)
         @Assert(s02.get(1),10)
         @Assert(s02.get(2),20)
         @Assert(s02.get(4),40)
         @Assert(s02.get(5),50)
         @Assert(s02.get(6),60)
         @Assert(s02.get(7),70)
    }
}