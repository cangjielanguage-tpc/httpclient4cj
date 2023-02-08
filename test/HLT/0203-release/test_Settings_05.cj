// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/http2

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