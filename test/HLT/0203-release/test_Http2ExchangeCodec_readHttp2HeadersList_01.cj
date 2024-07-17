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
import std.log.*
import std.collection.*


@Test
public class okhttp_readHttp2HeadersList_001{
    @TestCase
    func okhttp_readHttp2HeadersList_001(): Unit {
        var headers=Header()
        headers.add(":status","200")
        var resp=Http2ExchangeCodec.readHttp2HeadersList(headers,httpclient4cj.Protocol.HTTP_2).build()
        @Assert(resp.getProtocol().toString(),"h2")
    }
}