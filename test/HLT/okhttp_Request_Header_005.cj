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
public class okhttp_Request_Header_005{

    @TestCase
    func okhttp_Request_Header_005(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1109/1234")
        let header: Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type", "application2/json")
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .method("GET")
                                        .header(header)
                                        .build()

        @Assert(request.getHeader("content-type1","aaa"),  "aaa")
    }

}

