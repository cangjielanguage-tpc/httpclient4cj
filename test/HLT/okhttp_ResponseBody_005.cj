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

@Test
public class okhttp_ResponseBody_005{


    @TestCase //ResponseBody.init() ContentLength = ResponseBody长度
    func okhttp_ResponseBody_005(): Unit {
        let arr = ByteArrayStream()
        arr.write("hello".toArray())
        var inputStream: InputStream = arr
        var source :OkBuffer = OkBuffer(inputStream)
        var response_body : ResponseBody = ResponseBody("text/plain; charset=utf-8",5,source)

        var str = response_body.getString()
        println("response_body =${str}")

        @Assert(str, "hello")

    }
}