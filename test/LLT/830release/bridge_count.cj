// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import socket.*
from encoding import url.*
from std import collection.*


main() {
    let parseUrl2 = URL.parse("http://www.jd.com/index.html")
    let arr  = ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])
    let a1 = Address(parseUrl2, arr)
    let r1 = Route(a1, SocketAddress("192.168.0.1",80))
    let conn = ConnectionPool()
    if(conn.connectionCount() == 0 && conn.idleConnectionCount() == 0) {
       conn.connectFailed(r1)
       conn.evictAll()
    }
    return 0
}