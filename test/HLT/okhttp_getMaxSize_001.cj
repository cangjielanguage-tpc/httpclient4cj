// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.fs.*

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