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