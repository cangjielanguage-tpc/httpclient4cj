// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import collection.*

@Test
public class okhttp_route_001{

    @TestCase
    func okhttp_route_001(): Unit {

        let parseUrl2 = URL.parse("http://www.jd.com/index.html")
        let arr  = ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])
        let adr = Address(parseUrl2, arr)
        let route = httpclient4cj.Route(adr, SocketAddress("192.168.0.1",80))
        println("route.getAddress() :${route.getAddress().getUrl()}")
        @Assert(route.getAddress().getUrl().toString(), "http://www.jd.com/index.html")
        println("route.getInetSocketAddress() :${route.getInetSocketAddress().address}")
        @Assert(route.getInetSocketAddress().address.toString(), "[192, 168, 0, 1]")
        println("route.hashCode() :${route.hashCode()}")
        @Assert(route.hashCode(), 42520901459)
    }

}

