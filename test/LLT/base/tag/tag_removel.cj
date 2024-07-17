// EXEC: cjc %import-path %L %l %f -V --link-options "-V"
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*
import std.time.*
import std.runtime.*
import net.http.*
import std.socket.*
import std.io.*
import std.sync.*
var port: UInt16 = 0

main() {
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
    .url("http://127.0.0.1:${port}/1234")
    .tag("test")
    .build()
    request.removeTag("test")
    request.getHeader("Host")
    println(request.toString())
    0
}