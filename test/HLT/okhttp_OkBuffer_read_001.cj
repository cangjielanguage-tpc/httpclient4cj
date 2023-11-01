// 3rd_party_lib:httpclient4cj/build/httpclient4cj

from std import io.*
from std import time.*
from httpclient4cj import httpclient4cj.*
from std import fs.*

@Test
public class okhttp_OkBuffer_read_001 {

    @TestCase
    func okhttp_OkBuffer_read_001(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001-----------------------------")
        var exc = ""
        try {
            File.delete("testData_okhttp_OkBuffer_read_001_2.txt")
        } catch (e:Exception){
            println("e.message = ${e.message}")
        }
        
        var file = File.create("testData_okhttp_OkBuffer_read_001_2.txt")
        file.write("hello world".toArray())
        file = File("testData_okhttp_OkBuffer_read_001_2.txt",OpenOption.Open(true, true))
        
        var okbuffer = OkBuffer(file)
        var byteArrayStream = ByteArrayStream(11)
        var arr = Array<Byte>(11,item:1)
        try {
            // println("okbuffer.readByte() = ${okbuffer.read(byteArrayStream,5)}")
            @Assert(okbuffer.read(byteArrayStream,11),11)
            byteArrayStream.read(arr)
            println("byteArrayStream.toString() = ${arr}")
            @Assert(arr,"hello world".toArray())

        } catch (e:Exception) {
            println("e.message = ${e.message}")
            exc = e.message 
        }
    }
    @TestCase
    func okhttp_OkBuffer_read_001_2(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001_2-----------------------------")

        var byteArrayStream = ByteArrayStream(11)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("hello world".toArray())

        var byteArrayStream2 = ByteArrayStream(11)
        @Assert(okbuffer.read(byteArrayStream2,11),11)
        
        var arr = Array<Byte>(11,item:1)
        byteArrayStream2.read(arr)
        println("byteArrayStream2.toString() = ${arr}")
        @Assert(arr,"hello world".toArray())
    }
    @TestCase
    func okhttp_OkBuffer_read_001_3(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001_3-----------------------------")

        var byteArrayStream = ByteArrayStream(11)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("hello world".toArray())

        var byteArrayStream2 = ByteArrayStream(11)
        @Assert(okbuffer.read(byteArrayStream2,1),1)
        
        var arr = Array<Byte>(11,item:1)
        byteArrayStream2.read(arr)
        println("byteArrayStream2.toString() = ${arr}")
        var arr2:Array<Byte> = [104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        @Assert(arr,arr2)
    }
    @TestCase
    func okhttp_OkBuffer_read_001_4(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001_4-----------------------------")

        var byteArrayStream = ByteArrayStream(11)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("hello world".toArray())
        var exc = ""
        try{
            var byteArrayStream2 = ByteArrayStream(11)
            okbuffer.read(byteArrayStream2,0)   
        } catch (e:Exception) {
            exc = e.message
        }
        
        @Assert(exc,"The buffer is Empty.")
    }
    @TestCase
    func okhttp_OkBuffer_read_001_5(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001_5-----------------------------")

        var byteArrayStream = ByteArrayStream(11)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("hello world".toArray())
        var exc = ""
        try{
            var byteArrayStream2 = ByteArrayStream(11)
            okbuffer.read(byteArrayStream2,-1)   
        } catch (e:NegativeArraySizeException) {
            // e.printStackTrace()
            exc = "NegativeArraySizeException"
        }
        
        @Assert(exc,"NegativeArraySizeException")
    }
    @TestCase
    func okhttp_OkBuffer_read_001_6(): Unit {
        println("---------------------------okhttp_OkBuffer_read_001_6-----------------------------")

        var byteArrayStream = ByteArrayStream(11)
        var okbuffer = OkBuffer(byteArrayStream)
        byteArrayStream.write("hello world".toArray())
        var byteArrayStream2 = ByteArrayStream(12)
        var exc = ""
        try{
            
            okbuffer.read(byteArrayStream2,12)   
        } catch (e:NegativeArraySizeException) {
            e.printStackTrace()
            exc = e.message
        }
        var arr = Array<Byte>(12,item:1)
        byteArrayStream2.read(arr)
        println("byteArrayStream2.toString() = ${arr}")
        var arr2:Array<Byte> = [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 1]
        @Assert(arr,arr2)
    }
}