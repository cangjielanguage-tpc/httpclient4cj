// 3rd_party_lib:httpclient4cj/build/httpclient4cj

from std import io.*
from std import time.*
from httpclient4cj import httpclient4cj.*
from std import fs.*

@Test
public class okhttp_indexOf_001 {

    @TestCase
    func okhttp_indexOf_001(): Unit {
        println("---------------------------okhttp_indexOf_001-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var arr :Array<UInt8> = [6,5,4,3,5,16,5]
        byteArrayStream.write(arr)
        println("byteArrayStream.length = ${byteArrayStream.length}")
        // println(okbuffer.indexOf(16,3,7))
        @Assert(okbuffer.indexOf(4,1,7),2)
    }
    @TestCase
    func okhttp_indexOf_001_2(): Unit {
        println("---------------------------okhttp_indexOf_001_2-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var arr :Array<UInt8> = [6,5,4,3,5,16,5]
        byteArrayStream.write(arr)
        // println(okbuffer.indexOf(5,2,7))
        @Assert(okbuffer.indexOf(5,2,7),4)
    }
    @TestCase
    func okhttp_indexOf_001_3(): Unit {
        println("---------------------------okhttp_indexOf_001_3-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            println(okbuffer.indexOf(0,2,7))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"EOF")
    }
    @TestCase
    func okhttp_indexOf_001_4(): Unit {
        println("---------------------------okhttp_indexOf_001_4-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            println(okbuffer.indexOf(0,8,7))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"from=8 to=7")
    }
    @TestCase
    func okhttp_indexOf_001_5(): Unit {
        println("---------------------------okhttp_indexOf_001_5-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            println(okbuffer.indexOf(0,1,0))
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"from=1 to=0")
    }
    @TestCase
    func okhttp_indexOf_001_6(): Unit {
        println("---------------------------okhttp_indexOf_001_6-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            // println(okbuffer.indexOf(16,1,10))
            @Assert(okbuffer.indexOf(16,1,10),5)
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"")
    }
    @TestCase
    func okhttp_indexOf_001_7(): Unit {
        println("---------------------------okhttp_indexOf_001_7-----------------------------")
        var exc = ""
        try {
            File.delete("../../testData/okhttp_indexOf_001_7.txt")
        } catch (e:Exception){
            println("e.message = ${e.message}")
        }
        try {
            var file = File.create("../../testData/okhttp_indexOf_001_7.txt")
            file.write("hello world".toArray())
            file = File("../../testData/okhttp_indexOf_001_7.txt",OpenOption.Open(true, true))
            
            var okbuffer = OkBuffer(file)
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())
            // println(okbuffer.readByte())

            // println(okbuffer.indexOf(108,4,11))
            @Assert(okbuffer.indexOf(108,4,11),9)  

        } catch (e:Exception) {
            println("e.message = ${e.message}")
            exc = e.message 
        }
    }
    @TestCase
    func okhttp_indexOf_001_8(): Unit {
        println("---------------------------okhttp_indexOf_001_8-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            @Assert(okbuffer.indexOf(16,-1,0),5)
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"from=-1 to=0")
    }
    @TestCase
    func okhttp_indexOf_001_9(): Unit {
        println("---------------------------okhttp_indexOf_001_9-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            @Assert(okbuffer.indexOf(16,1,-0),5)
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"from=1 to=0")
    }
    @TestCase
    func okhttp_indexOf_001_10(): Unit {
        println("---------------------------okhttp_indexOf_001_10-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(10)
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [6,5,4,3,5,16,5]
            byteArrayStream.write(arr)
            @Assert(okbuffer.indexOf(16,1,-1),5)
        } catch (e:Exception){
            exc = e.message
        }
        @Assert(exc,"from=1 to=-1")
    }
}