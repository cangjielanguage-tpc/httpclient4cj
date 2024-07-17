// 3rd_party_lib:httpclient4cj/build/httpclient4cj

import std.io.*
import std.time.*
import httpclient4cj
import httpclient4cj.*
import std.fs.*

@Test
public class okhttp_skipBuffer_001 {

    @TestCase
    func okhttp_skipBuffer_001(): Unit {
        println("---------------------------okhttp_skipBuffer_001-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var arr :Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        byteArrayStream.write(arr)
        println(okbuffer.readByte())
        println(okbuffer.readByte())
        okbuffer.skipBuffer(1)
        @Assert(okbuffer.readByte(),3)  
        okbuffer.skipBuffer(3)
        println(okbuffer.readByte())
        okbuffer.skipBuffer(0)
        @Assert(okbuffer.readByte(),8)
    }
    @TestCase
    func okhttp_skipBuffer_001_2(): Unit {
        println("---------------------------okhttp_skipBuffer_001_2-----------------------------")
        var exc = ""
        try {
            File.delete("../../testData/okhttp_skipBuffer_001_2.txt")
        } catch (e:Exception){
            println("e.message = ${e.message}")
        }
        try {
            var file = File.create("../../testData/okhttp_skipBuffer_001_2.txt")
            file.write("hello world".toArray())
            file = File("../../testData/okhttp_skipBuffer_001_2.txt",OpenOption.Open(true, true))
            

            var okbuffer = OkBuffer(file)
            println("okbuffer.readByte() = ${okbuffer.readByte()}")
            okbuffer.skipBuffer(1)
            @Assert(okbuffer.readByte(),108)
            okbuffer.skipBuffer(7)
            @Assert(okbuffer.readByte(),100)  

        } catch (e:Exception) {
            println("e.message = ${e.message}")
            exc = e.message 
        }
    }
    @TestCase
    func okhttp_skipBuffer_001_3(): Unit {
        println("---------------------------okhttp_skipBuffer_001_3-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(0) 
            var okbuffer = OkBuffer(byteArrayStream)
            println(okbuffer.skipBuffer(1))
        } catch (e:Exception){
            exc = e.message
        }
        println(exc)
        @Assert(exc,"EOF")  
    }
    @TestCase
    func okhttp_skipBuffer_001_4(): Unit {
        println("---------------------------okhttp_skipBuffer_001_4-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(0) 
            var okbuffer = OkBuffer(byteArrayStream)
            println(okbuffer.skipBuffer(-1))
        } catch (e:Exception){
            exc = e.message
        }
        println(exc)
        @Assert(exc,"limit = -1 < 0")  
    }
}