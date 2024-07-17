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
public class okhttp_address_hashCode_001 {
    let arr = [httpclient4cj.Protocol.get("h2_prior_knowledge").toString(),
        httpclient4cj.Protocol.get("HTTP/1.1").toString()]
    let url: URL = URL.parse("http://127.0.0.1:1105/1234")

    @TestCase
    func okhttp_address_hashCode_001(): Unit {
        var address: Address = Address(url, ArrayList<String>(arr))
        println(address.hashCode())

        @Assert(address.hashCode(), hashcode())
    }

    @OverflowWrapping
    func hashcode(): Int {
        var result: Int64 = 17
        result = 31 * result + url.toString().hashCode()
        var listCode = 1
        for (i in 0..arr.size) {
            listCode = 31 * listCode + arr[i].toString().hashCode()
        }
        result = 31 * result + listCode
        result
    }
}
