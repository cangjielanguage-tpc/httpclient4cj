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
import std.collection.*

@Test
public class okhttp_address_getProtocols_001{

    @TestCase
    func okhttp_address_getProtocols_001(): Unit {

        let url : URL = URL.parse("http://127.0.0.1:1105/1234")
        var address : Address = Address(url,ArrayList<String>([httpclient4cj.Protocol.get("h2_prior_knowledge").toString(),
         httpclient4cj.Protocol.get("HTTP/1.1").toString()]))
        println(address.getUrl())
        @Assert(address.getUrl().toString(), "http://127.0.0.1:1105/1234")
        println(address.getProtocols())
        @Assert(address.getProtocols().toString(), "[h2_prior_knowledge, http/1.1]")
    }

}

