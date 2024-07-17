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