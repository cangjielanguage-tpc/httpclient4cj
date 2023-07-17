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
from std import fs.*

@Test
public class okhttp_cacheDirectory_001 {
    
    @TestCase
    func okhttp_cacheDirectory_001(): Unit {
        try{
            Directory.delete("./cacheDirectory")
        } catch(e:Exception){

        }
        let cache: Cache = Cache("./cacheDirectory", 10 * 1024 * 1024)
        cache.getDirectory().createFile("test_getDirectory.txt")
        @Assert(Directory.exists("./cacheDirectory"),true) 
    }
}