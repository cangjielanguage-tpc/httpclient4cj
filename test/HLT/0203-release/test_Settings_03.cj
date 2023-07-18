// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj


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
from std import math.*
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