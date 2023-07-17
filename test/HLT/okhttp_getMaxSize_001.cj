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
from std import fs.*

@Test
public class okhttp_getMaxSize_001 {
    
    @TestCase
    func okhttp_getMaxSize_001(): Unit {
        
        let cache: Cache = Cache("./cacheDirectory", 10 * 1024 * 1024)
        println("cache.getMaxSize() ${cache.getMaxSize()}")
        @Assert(cache.getMaxSize(),10 * 1024 * 1024)

    }
    @TestCase
    func okhttp_getMaxSize_001_2(): Unit {
        var exc = ""
        try{
            let cache: Cache = Cache("./cacheDirectory2", 0)
            println("cache.getMaxSize() ${cache.getMaxSize()}")
        }catch(e:IllegalArgumentException){
            exc = e.message
        }
        
        @Assert(exc,"maxSize <= 0")

    }
    @TestCase
    func okhttp_getMaxSize_001_3(): Unit {
        var exc = ""
        try{
            Cache("./cacheDirectory3", -1)
        }catch(e:IllegalArgumentException){
            exc = e.message
        }
        
        @Assert(exc,"maxSize <= 0")

    }
}