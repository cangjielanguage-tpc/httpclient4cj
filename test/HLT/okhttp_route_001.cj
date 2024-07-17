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
public class okhttp_route_001{
    let parseUrl2 = URL.parse("http://www.jd.com/index.html")
    let arr  = ArrayList<String>([httpclient4cj.Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])
    let adr = Address(parseUrl2, arr)

    @TestCase
    func okhttp_route_001(): Unit {

        let route = httpclient4cj.Route(adr, SocketAddress("192.168.0.1",80))
        println("route.getAddress() :${route.getAddress().getUrl()}")
        @Assert(route.getAddress().getUrl().toString(), "http://www.jd.com/index.html")
        println("route.getInetSocketAddress() :${route.getInetSocketAddress().address}")
        @Assert(route.getInetSocketAddress().address.toString(), "[192, 168, 0, 1]")
        println("route.hashCode() :${route.hashCode()}")
        @Assert(route.hashCode(), hashCode())
    }
    
    @OverflowWrapping
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = 31 * result + adr.hashCode()

        //result = 31 * result + inetSocketAddress.hashCode()
        return result
    }

}

