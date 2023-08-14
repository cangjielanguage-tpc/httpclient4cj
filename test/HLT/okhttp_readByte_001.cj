// 3rd_party_lib:httpclient4cj/build/httpclient4cj

from std import io.*
from std import time.*
from httpclient4cj import httpclient4cj.*
from std import fs.*

@Test
public class okhttp_readByte_001 {

    @TestCase
    func okhttp_readByte_001(): Unit {
        println("---------------------------okhttp_readByte_001-----------------------------")
        var byteArrayStream = ByteArrayStream(10)
        var okbuffer = OkBuffer(byteArrayStream)
        var arr :Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        byteArrayStream.write(arr)
        println(okbuffer.readByte())
        println(okbuffer.readByte())
        @Assert(okbuffer.readByte(),2)  
    }
    @TestCase
    func okhttp_readByte_001_2(): Unit {
        println("---------------------------okhttp_readByte_001_2-----------------------------")
        var exc = ""
        try {
            File.delete("../../testData/okhttp_readByte_001_2.txt")
        } catch (e:Exception){
            println("e.message = ${e.message}")
        }
        try {
            var file = File.create("../../testData/okhttp_readByte_001_2.txt")
            file.write("hello world".toUtf8Array())
            file = File("../../testData/okhttp_readByte_001_2.txt",OpenOption.Open(true, true))
            

            var okbuffer = OkBuffer(file)
            println("okbuffer.readByte() = ${okbuffer.readByte()}")
            println("okbuffer.readByte() = ${okbuffer.readByte()}")
            @Assert(okbuffer.readByte(),108)  

        } catch (e:Exception) {
            println("e.message = ${e.message}")
            exc = e.message 
        }
    }
    @TestCase
    func okhttp_readByte_001_3(): Unit {
        println("---------------------------okhttp_readByte_001_3-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(0) 
            var okbuffer = OkBuffer(byteArrayStream)
            println(okbuffer.readByte())
        } catch (e:Exception){
            exc = e.message
        }
        println(exc)
        @Assert(exc,"EOF")  
    }
    @TestCase
    func okhttp_readByte_001_4(): Unit {
        println("---------------------------okhttp_readByte_001_4-----------------------------")
        var exc = ""
        try{
            var byteArrayStream = ByteArrayStream(0) 
            var okbuffer = OkBuffer(byteArrayStream)
            var arr :Array<UInt8> = [0, 1]
            byteArrayStream.write(arr)
            println(okbuffer.readByte())
            println(okbuffer.readByte())
            println(okbuffer.readByte())
        } catch (e:Exception){
            exc = e.message
        }
        println(exc)
        @Assert(exc,"EOF")  
    }
}