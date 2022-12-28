// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*
from std import time.*
from std import runtime.*
from net import http.*
from std import socket.*
from std import io.*
from std import sync.*
var port: UInt16 = 0

main() {
    let request: okhttp.Request = okhttp.Request.builder()
    .url("http://127.0.0.1:${port}/1234")
    .tag("test")
    .build()
    request.removeTag("test")
    request.getHeader("Host")
    println(request.toString())
    0
}