// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import httpclient4cj
import httpclient4cj.*
import net.http.*
import std.collection.*
import encoding.url.*
import net.tls.*
import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import std.time.*
import std.socket.*

@Test
public class okhttp_Protocol_001{

    @TestCase
    func okhttp_Protocol_001(): Unit {
        let protocol_1 = httpclient4cj.Protocol.get("http/1.0")
        @Assert(protocol_1 is httpclient4cj.Protocol,true)
        @Assert(protocol_1.toString(),HTTP_1_0.toString())

        let protocol_2 = httpclient4cj.Protocol.get("HTTP/1.0")
        @Assert(protocol_2 is httpclient4cj.Protocol,true)
        @Assert(protocol_2.toString(),HTTP_1_0.toString())

        let protocol_3 = httpclient4cj.Protocol.get("http/1.1")
        @Assert(protocol_3 is httpclient4cj.Protocol,true)
        @Assert(protocol_3.toString(),HTTP_1_1.toString())

        let protocol_4 = httpclient4cj.Protocol.get("HTTP/1.1")
        @Assert(protocol_4 is httpclient4cj.Protocol,true)
        @Assert(protocol_4.toString(),HTTP_1_1.toString())

        // let protocol_5 = httpclient4cj.Protocol.get("spdy/3.1")
        // @Assert(protocol_5 is httpclient4cj.Protocol,true)
        // @Assert(protocol_5.toString(),SPDY_3.toString())

        // let protocol_6 = httpclient4cj.Protocol.get("SPDY/3.1")
        // @Assert(protocol_6 is httpclient4cj.Protocol,true)
        // @Assert(protocol_6.toString(),SPDY_3.toString())

        let protocol_7 = httpclient4cj.Protocol.get("h2")
        @Assert(protocol_7 is httpclient4cj.Protocol,true)
        @Assert(protocol_7.toString(),HTTP_2.toString())

        let protocol_8 = httpclient4cj.Protocol.get("H2")
        @Assert(protocol_8 is httpclient4cj.Protocol,true)
        @Assert(protocol_8.toString(),HTTP_2.toString())

        let protocol_9 = httpclient4cj.Protocol.get("http/2.0")
        @Assert(protocol_9 is httpclient4cj.Protocol,true)
        @Assert(protocol_9.toString(),HTTP_2.toString())

        let protocol_10 = httpclient4cj.Protocol.get("HTTP/2.0")
        @Assert(protocol_10 is httpclient4cj.Protocol,true)
        @Assert(protocol_10.toString(),HTTP_2.toString())

        let protocol_11 = httpclient4cj.Protocol.get("h2_prior_knowledge")
        @Assert(protocol_11 is httpclient4cj.Protocol,true)
        @Assert(protocol_11.toString(),H2_PRIOR_KNOWLEDGE.toString())

        let protocol_12 = httpclient4cj.Protocol.get("H2_PRIOR_KNOWLEDGE")
        @Assert(protocol_12 is httpclient4cj.Protocol,true)
        @Assert(protocol_12.toString(),H2_PRIOR_KNOWLEDGE.toString())

        // let protocol_13 = httpclient4cj.Protocol.get("quic")
        // @Assert(protocol_13 is httpclient4cj.Protocol,true)
        // @Assert(protocol_13.toString(),QUIC.toString())

        // let protocol_14 = httpclient4cj.Protocol.get("QUIC")
        // @Assert(protocol_14 is httpclient4cj.Protocol,true)
        // @Assert(protocol_14.toString(),QUIC.toString())

        var exc : String = ""
        try {
            httpclient4cj.Protocol.get("ABC")
        } catch(e: Exception) {
            exc = e.message
        }
        @Assert(exc, "no find protocol")

        let protocol_16 = HTTP_1_0.toString()
        @Assert(protocol_16, "http/1.0")

        let protocol_17 = HTTP_1_1.toString()
        @Assert(protocol_17, "http/1.1")

        // let protocol_18 = SPDY_3.toString()
        // @Assert(protocol_18, "spdy/3.1")

        let protocol_19 = HTTP_2.toString()
        @Assert(protocol_19, "h2")

        let protocol_20 = H2_PRIOR_KNOWLEDGE.toString()
        @Assert(protocol_20, "h2_prior_knowledge")

        // let protocol_21 = QUIC.toString()
        // @Assert(protocol_21, "quic")

    }
}

