// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// sources_file: RealRequestBody.html

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

@Test
public class okhttp_RequestBody_006{

    @TestCase //test RealRequestBody
    func okhttp_RequestBody_006(): Unit {
        println(Directory(".").info.path)
        
        var file: File = File("RealRequestBody.html",OpenOption.Open(true,true))
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("POST",body: RealRequestBody.create(MediaType.get("application/json"),file))
                                        .build()
        // test contentType
        var body_Type = request.getBody().getOrThrow().contentType().getOrThrow().toString()
        @Assert(body_Type, "application/json")
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

