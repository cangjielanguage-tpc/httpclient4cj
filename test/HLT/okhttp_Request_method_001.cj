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
public class okhttp_Request_method_001{

    @TestCase
    func okhttp_Request_method_001(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .method("GET")
                                        .build()
        var request_method = request.getMethod()
        println(request_method)
        @Assert(request_method, "GET")

    }
    @TestCase
    func okhttp_Request_method_001_exception(): Unit {
        var exception = ""
        let body: httpclient4cj.RequestBody = httpclient4cj.RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "hello".toArray())
        try{
            let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                            .method("GET",body:body)
                                            .build()
            request.getMethod()
            
        } catch (e : Exception) {
            println("e.message = ${e.message}")
            exception = e.message
        }
        @Assert(exception.contains("method GET must not have a request body."), true)

    }

}

