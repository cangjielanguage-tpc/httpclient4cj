// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/http2

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from std import time.*
from std import socket.*

@Test
public class okhttp_Protocol_001{

    @TestCase
    func okhttp_Protocol_001(): Unit {
        let protocol_1 = Protocol.get("http/1.0")
        @Assert(protocol_1 is Protocol,true)
        @Assert(protocol_1.toString(),HTTP_1_0.toString())

        let protocol_2 = Protocol.get("HTTP/1.0")
        @Assert(protocol_2 is Protocol,true)
        @Assert(protocol_2.toString(),HTTP_1_0.toString())

        let protocol_3 = Protocol.get("http/1.1")
        @Assert(protocol_3 is Protocol,true)
        @Assert(protocol_3.toString(),HTTP_1_1.toString())

        let protocol_4 = Protocol.get("HTTP/1.1")
        @Assert(protocol_4 is Protocol,true)
        @Assert(protocol_4.toString(),HTTP_1_1.toString())

        let protocol_5 = Protocol.get("spdy/3.1")
        @Assert(protocol_5 is Protocol,true)
        @Assert(protocol_5.toString(),SPDY_3.toString())

        let protocol_6 = Protocol.get("SPDY/3.1")
        @Assert(protocol_6 is Protocol,true)
        @Assert(protocol_6.toString(),SPDY_3.toString())

        let protocol_7 = Protocol.get("h2")
        @Assert(protocol_7 is Protocol,true)
        @Assert(protocol_7.toString(),HTTP_2.toString())

        let protocol_8 = Protocol.get("H2")
        @Assert(protocol_8 is Protocol,true)
        @Assert(protocol_8.toString(),HTTP_2.toString())

        let protocol_9 = Protocol.get("http/2.0")
        @Assert(protocol_9 is Protocol,true)
        @Assert(protocol_9.toString(),HTTP_2.toString())

        let protocol_10 = Protocol.get("HTTP/2.0")
        @Assert(protocol_10 is Protocol,true)
        @Assert(protocol_10.toString(),HTTP_2.toString())

        let protocol_11 = Protocol.get("h2_prior_knowledge")
        @Assert(protocol_11 is Protocol,true)
        @Assert(protocol_11.toString(),H2_PRIOR_KNOWLEDGE.toString())

        let protocol_12 = Protocol.get("H2_PRIOR_KNOWLEDGE")
        @Assert(protocol_12 is Protocol,true)
        @Assert(protocol_12.toString(),H2_PRIOR_KNOWLEDGE.toString())

        let protocol_13 = Protocol.get("quic")
        @Assert(protocol_13 is Protocol,true)
        @Assert(protocol_13.toString(),QUIC.toString())

        let protocol_14 = Protocol.get("QUIC")
        @Assert(protocol_14 is Protocol,true)
        @Assert(protocol_14.toString(),QUIC.toString())

        var exc : String = ""
        try {
            let protocol_15 = Protocol.get("ABC")
        } catch(e: Exception) {
            exc = e.getMessage()
        }
        @Assert(exc, "no find protocol")

        let protocol_16 = HTTP_1_0.toString()
        @Assert(protocol_16, "http/1.0")

        let protocol_17 = HTTP_1_1.toString()
        @Assert(protocol_17, "http/1.1")

        let protocol_18 = SPDY_3.toString()
        @Assert(protocol_18, "spdy/3.1")

        let protocol_19 = HTTP_2.toString()
        @Assert(protocol_19, "h2")

        let protocol_20 = H2_PRIOR_KNOWLEDGE.toString()
        @Assert(protocol_20, "h2_prior_knowledge")

        let protocol_21 = QUIC.toString()
        @Assert(protocol_21, "quic")

    }
}

