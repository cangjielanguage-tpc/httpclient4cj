// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from http2 import proto.*
from http2 import http.*
from std import socket.*
from net import http.* as h1.*

main() {
    let socket = Socket(TCP,"127.0.0.1", 50066)
    socket.connect()
    let conn  = H2ClientConn.createClientConn(H2Transport(), socket)
    let r = H2Request(GET, "http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello");
    var ssv = StringStream("")
            r.req.write(ssv)
    println(ssv.toString())

    let r2 = h1.Request(GET, "http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello");
    var ssv2 = StringStream("")
                r2.write(ssv2)
        println(ssv2.toString())

    let resp = conn.doRequest(r)
    println(resp.status)
    showResp(resp,"TEST")
}

func showResp(resp: H2Response, msg: String) {
let xfix = String(Array<Char>(20, item: '*'))
println("${xfix} ${msg} ${xfix}")
println("status: ${resp.status}")
println("statusCode: ${resp.statusCode}")
println("proto: ${resp.proto}")
println("protoMajor: ${resp.protoMajor}")
println("protoMinor: ${resp.protoMinor}")
println("transferEncoding: ${resp.transferEncoding}")
println("contentLength: ${resp.contentLength}")
println("----------------respbody------------------------")
var ss = resp.body as StringStream
var s: String = String(ss.getOrThrow().getChars())
println("body ==> ${s}")
var buf = Array<UInt8>(100, {i => 0})
println("----------------respbody------------------------")
var num = resp.body.read(buf)
println("num ==> ${num}")
println("----------------respbody---------${num}---------------") }