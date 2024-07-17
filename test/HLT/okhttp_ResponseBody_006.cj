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
public class okhttp_ResponseBody_006{


    @TestCase //ResponseBody.init() ContentLength<>ResponseBody长度
    func okhttp_ResponseBody_006(): Unit {
        let arr = ByteArrayStream()
        arr.write("hello".toArray())
        var inputStream: InputStream = arr
        var source : OkBuffer = OkBuffer(inputStream)
        var response_body : ResponseBody = ResponseBody("text/plain; charset=utf-8",4,source)
        
        var response_body_contentLength : Int64 = response_body.getContentLength()
        println("response_body_contentLength =${response_body_contentLength}")
        @Assert(response_body_contentLength, 4)//根据设定的值获取

        var str = response_body.getString()
        println("response_body =[${str}]")
        @Assert(str, "hello")

    }
}