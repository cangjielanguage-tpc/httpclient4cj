// 3rd_party_lib:okhttp/build/okhttp


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