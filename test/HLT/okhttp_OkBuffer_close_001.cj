// 3rd_party_lib:httpclient4cj/build/httpclient4cj

import std.io.*
import std.time.*
import httpclient4cj
import httpclient4cj.*
import std.fs.*

@Test
public class okhttp_OkBuffer_close_001 {

    @TestCase
    func okhttp_OkBuffer_close_001(): Unit {
        println("---------------------------okhttp_OkBuffer_close_001-----------------------------")
        var exc = ""
        try {
            File.delete("testData_okhttp_OkBuffer_close_001_2.txt")
        } catch (e:Exception){
            println("e.message = ${e.message}")
        }
        
        var file = File.create("testData_okhttp_OkBuffer_close_001_2.txt")
        file.write("hello world".toArray())
        file = File("testData_okhttp_OkBuffer_close_001_2.txt",OpenOption.Open(true, true))
        
        var okbuffer = OkBuffer(file)
        try {
            println("okbuffer.readByte() = ${okbuffer.readByte()}")
            println("okbuffer.readByte() = ${okbuffer.readByte()}")
            @Assert(okbuffer.readByte(),108)  

            println("okbuffer.isClosed() = ${okbuffer.isClosed()}")
            println("file.isClosed() = ${file.isClosed()}")
            okbuffer.close()
            println("okbuffer.isClosed() = ${okbuffer.isClosed()}")
            println("file.isClosed() = ${file.isClosed()}")
            @Assert(okbuffer.isClosed(),true) 

            println("okbuffer.readByte() = ${okbuffer.readByte()}")

        } catch (e:Exception) {
            // e.printStackTrace()
            println("e.message = ${e.message}")
            exc = e.message 
        }
        @Assert(exc,"The file not opened, can not to read.") 

        file = File("testData_okhttp_OkBuffer_close_001_2.txt",OpenOption.Open(true, true))
        okbuffer = OkBuffer(file)
        println("okbuffer.readByte() = ${okbuffer.readByte()}")
        @Assert(okbuffer.readByte(),101) 
    }
}