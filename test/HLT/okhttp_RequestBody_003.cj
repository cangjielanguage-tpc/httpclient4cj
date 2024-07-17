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
public class okhttp_RequestBody_003{

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_003(): Unit {
        let body: httpclient4cj.RequestBody = RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),"hello".toArray())
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("POST",body: body)
                                        .build()
        // test contentType
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        @Assert(body_Type, "application/json; charset=utf-8")
        // test getContentLength
        var body_Length = request.getBody().getOrThrow().getContentLength()
        @Assert(body_Length, Int64(5))
        //test get
        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toArray())

    }

}

