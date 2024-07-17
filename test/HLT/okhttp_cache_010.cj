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
public class okhttp_cache_010 {
   
    @TestCase
    func okhttp_cache_010(): Unit {

        let cache: Cache = Cache("./okhttp_cache_010", 10 * 1024 * 1024)
        cache.initialize()
        @Assert(File.exists("./okhttp_cache_010/journal"),true)
    }
}