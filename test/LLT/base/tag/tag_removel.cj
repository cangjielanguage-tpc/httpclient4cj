// EXEC: cjc %import-path %L %l %f -V --link-options "-V"
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import collection.*
from std import time.*
from std import runtime.*
from net import http.*
from std import socket.*
from std import io.*
from std import sync.*
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