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
from std import fs.*

@Test
public class okhttp_cache_010 {
   
    @TestCase
    func okhttp_cache_010(): Unit {

        let cache: Cache = Cache("./okhttp_cache_010", 10 * 1024 * 1024)
        cache.initialize()
        @Assert(File.exists("./okhttp_cache_010/journal"),true)
    }
}