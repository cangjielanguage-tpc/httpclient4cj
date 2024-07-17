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
public class okhttp_Request_Header_002{

    @TestCase
    func okhttp_Request_Header_002(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1106/1234")
        let header: Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()
        println("http_heads")
        for ((nm,vl) in header) {
            println(nm)
            println(vl.toString())
        }

        println("okhttp_heads")
        for ((nm,vl) in request.getHeaders()) {
            println(nm)
            println(vl.toString())
        }
        println("http_heads_get")
        for (vl in header.getAll("content-type")) {
            println(vl)
        }
        println("okhttp_heads_get")
        println(request.getHeader("content-type").getOrThrow())
        println("okhttp_heads_getHeaders")
        for (vl in request.getHeaders().getAll("content-type")) {
            println(vl.toString())
        }
        @Assert(request.getHeaders().getAll("content-type")[0],  "application/json")
        @Assert(request.getHeaders().getAll("content-type")[1],  "application2/json")
    }

}

