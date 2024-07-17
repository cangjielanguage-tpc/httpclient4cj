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
public class okhttp_Request_method_002{

    @TestCase
    func okhttp_Request_method_002(): Unit {
        let body: httpclient4cj.RequestBody = httpclient4cj.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toArray())
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("PUT",body:body)
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "PUT")

        var str_body:Array<Byte> = Array<Byte>(5, item: 0)
        request.getBody().getOrThrow().get().read(str_body)
        println(String.fromUtf8(str_body))
        @Assert(str_body, "hello".toArray())

    }
    
    @TestCase
    func okhttp_Request_method_002_exception(): Unit {
        var exception = ""
        try{
            let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                            .method("PUT")
                                            .build()
            request.getMethod()
        } catch (e : Exception) {
            println("e.message = ${e.message}")
            exception = e.message
        }
        @Assert(exception.contains("method PUT must have a request body."), true)

    }

}

