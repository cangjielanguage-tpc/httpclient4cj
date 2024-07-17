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
public class okhttp_Request_url_001{

    @TestCase
    func okhttp_Request_url_001(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1111/1234")
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .build()
        var request_url = request.getUrl().toString()
        println(request_url)
        @Assert(request_url, "http://127.0.0.1:1111/1234")

    }

}

