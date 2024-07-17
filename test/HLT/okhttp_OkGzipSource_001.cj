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
import compress.zlib.*

@Test
public class okhttp_OkGzipSource_001 {

    @TestCase 
    func okhttp_OkGzipSource_001(): Unit {
        println("1111111111")
        var arr = ByteArrayStream()
        println("2222222222")
        var cotps = CompressOutputStream(arr,wrap:GzipFormat)
        println("3333333333")
        cotps.write("hello world".toArray())
        println("444444444411111111111111")
        cotps.flush()
        println("4444444444")
        println("arr.length ${arr.length}")
        var okbf = OkBuffer(arr)
        println("arr.length ${arr.length}")
        println("5555555555")
        OkGzipSource(okbf)
        println("6666666666")
        ByteArrayStream()
        println("7777777777")
        // var gzipInt64 = gzip.read(arr2, 1)
        // print("gzipInt64 = ${gzipInt64}")

        // println(String.fromUtf8(arr2.bytes()))
    }
}