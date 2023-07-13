// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


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

@Test
public class okhttp_Settings_06{
    @TestCase
    func okhttp_getHeaderTableSize_001(): Unit {
         var s01=Settings()
         @Assert(s01.getHeaderTableSize(),-1)
    }
    @TestCase
    func okhttp_getHeaderTableSize_002(): Unit {
         var s01=Settings()
         s01.setting(1,10)
         s01.setting(2,20)
         s01.setting(4,40)
         s01.setting(5,50)
         s01.setting(6,60)
         s01.setting(7,70)
         @Assert(s01.getHeaderTableSize(),10)
    }
}