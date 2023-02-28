// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

from std import io.*
from std import time.*
from okhttp import okhttp.*
from std import fs.*

@Test
public class okhttp_readUtf8Line_001 {

    @TestCase
    func okhttp_readUtf8Line_001(): Unit {
        println("---------------------------okhttp_readUtf8Line_001-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\n中国".toUtf8Array())

        // println(okbuffer.readUtf8Line())
        @Assert(okbuffer.readUtf8Line(),"华为")
    }
    @TestCase
    func okhttp_readUtf8Line_001_2(): Unit {
        println("---------------------------okhttp_readUtf8Line_001_2-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为中国".toUtf8Array())
        var exc = ""
        try{
            println(okbuffer.readUtf8Line())
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"EOF")
    }
    @TestCase
    func okhttp_readUtf8Line_001_3(): Unit {
        println("---------------------------okhttp_readUtf8Line_001_3-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\n".toUtf8Array())

        // println(okbuffer.readUtf8Line())
        @Assert(okbuffer.readUtf8Line(),"华为")
    }
    @TestCase
    func okhttp_readUtf8Line_001_4(): Unit {
        println("---------------------------okhttp_readUtf8Line_001_4-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var exc = ""
        try{
            println(okbuffer.readUtf8Line())
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"EOF")
    }
    @TestCase
    func okhttp_readUtf8Line_001_5(): Unit {
        println("---------------------------okhttp_readUtf8Line_001_5-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\r\n中国".toUtf8Array())

        // println(okbuffer.readUtf8Line())
        @Assert(okbuffer.readUtf8Line(),"华为\r")
    }
}