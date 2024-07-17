// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.socket.*
import encoding.url.*
import std.collection.*


main() {
    let parseUrl2 = URL.parse("http://www.jd.com/index.html")
    let arr  = ArrayList<String>([httpclient4cj.Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])
    let a1 = Address(parseUrl2, arr)
    let r1 = Route(a1, SocketAddress("192.168.0.1",80))
    let r2 = Route(a1, SocketAddress("192.168.0.1",80))
    if (r1 != r2) {
        return -1
    }
    return 0
}