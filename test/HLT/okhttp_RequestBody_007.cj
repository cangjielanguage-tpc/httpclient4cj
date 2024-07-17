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

let arr = ByteArrayStream()
class RequestBodySink<: Sink {

    public func write(bytes: Array<Byte>): Unit {
        arr.write(bytes)
        return ()
    }
    public func flush(): Unit {
    }
    public func close(): Unit {
    }

}

@Test
public class okhttp_RequestBody_writeTo {

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_writeTo(): Unit {
        var body : RequestBodySink = RequestBodySink()
        let RealRequestBody = httpclient4cj.RealRequestBody.create(MediaType.get("application/json"),"hello".toArray())
        RealRequestBody.writeTo(body)
        //println(String.fromUtf8(arr.readToEnd()))
        @Assert(String.fromUtf8(arr.readToEnd()), "hello")
    }
}