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
    var ssv = ByteArrayStream()
    r.req.copyTo(ssv)
    println(String(okhttp.toArray(ssv.readToEnd())))
    let r2 = h1.Request(GET, "http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello");
    var ssv2 = ByteArrayStream()
    r2.copyTo(ssv2)
    println(String(okhttp.toArray(ssv2.readToEnd())))
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
var ss = resp.body as ByteArrayStream
var s: String = String(okhttp.toArray(ss.getOrThrow().readToEnd()))
println("body ==> ${s}")
var buf = Array<UInt8>(100, {i => 0})
println("----------------respbody------------------------")
var num = resp.body.read(buf)
println("num ==> ${num}")
println("----------------respbody---------${num}---------------") }