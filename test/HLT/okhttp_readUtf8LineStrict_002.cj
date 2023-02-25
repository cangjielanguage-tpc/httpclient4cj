// 3rd_party_lib:okhttp/build/okhttp

from std import io.*
from std import time.*
from okhttp import okhttp.*
from std import fs.*

@Test
public class okhttp_readUtf8LineStrict_002 {

    @TestCase
    func okhttp_readUtf8LineStrict_002(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\r\n中国".toUtf8Array())

        // println(okbuffer.readUtf8LineStrict())
        @Assert(okbuffer.readUtf8LineStrict(7),"华为")
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_2(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_2-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为中国".toUtf8Array())
        var exc = ""
        try{
            println(okbuffer.readUtf8LineStrict(18))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"EOF")
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_3(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_3-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\r\n中国".toUtf8Array())
        var exc = ""
        try{
            // println("okbuffer.readUtf8LineStrict(0) = ${okbuffer.readUtf8LineStrict(0)}")
            @Assert(okbuffer.readUtf8LineStrict(0),"")
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,##"can't find CRLF line"##)
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_4(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_4-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\r\n中国".toUtf8Array())
        var exc = ""
        try{
            println(okbuffer.readUtf8LineStrict(-1))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"limit < 0: -1")
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_5(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_5-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\r\n中国".toUtf8Array())
        var exc = ""
        try{
            // println(okbuffer.readUtf8LineStrict(1))
            @Assert(okbuffer.readUtf8LineStrict(1),"")
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,##"can't find CRLF line"##)
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_6(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_6-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var exc = ""
        try{
            println(okbuffer.readUtf8LineStrict(10))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"EOF")
    }
    @TestCase
    func okhttp_readUtf8LineStrict_002_7(): Unit {
        println("---------------------------okhttp_readUtf8LineStrict_002_7-----------------------------")

        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("华为\n中国".toUtf8Array())
        var exc = ""
        try{
            println(okbuffer.readUtf8LineStrict(10))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,##"can't find CRLF line"##)
    }
}