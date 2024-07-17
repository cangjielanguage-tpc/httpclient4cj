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
import std.math.*

class subSink <: Sink{
    public init(){}
    public func write(bytes: Array<Byte>){}
    public func flush(){}
    public func close(){}
}
@Test
public class okhttp_RealBufferSink_01{
    @TestCase
    func okhttp_RealBufferSink_close_001(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>()
        rb.write(bs)
        rb.close()
    }
    @TestCase
    func okhttp_RealBufferSink_close_002(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>(10000,item:9)
        rb.write(bs)
        rb.flush()
        rb.close()
    }
    @TestCase
    func okhttp_RealBufferSink_close_003(): Unit {
        var rb = RealBufferSink(subSink())
        var bs=Array<Byte>(10000,item:9)
        rb.write(bs)
        rb.flush()
        rb.write(bs)
        rb.close()
        var flag=0
        try{
            rb.flush()
        }catch(e:Exception){
            if(e.toString().contains("closed")==true){
                flag=1
            }
        }
        @Assert(flag,1)
    }
}