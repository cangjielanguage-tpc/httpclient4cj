// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import collection.*

@Test
public class okhttp_address_getProtocols_001{

    @TestCase
    func okhttp_address_getProtocols_001(): Unit {

        let url : URL = URL.parse("http://127.0.0.1:1105/1234")
        var address : Address = Address(url,ArrayList<String>([Protocol.get("h2_prior_knowledge").toString(),
         Protocol.get("HTTP/1.1").toString()]))
        println(address.getUrl())
        @Assert(address.getUrl().toString(), "http://127.0.0.1:1105/1234")
        println(address.getProtocols())
        @Assert(address.getProtocols().toString(), "[h2_prior_knowledge, http/1.1]")
    }

}

