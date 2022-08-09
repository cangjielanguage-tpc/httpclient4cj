// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from net import http.*
from std import socket.*
from okhttp import okhttp.*
from std import io.*
from std import time.*

main() {
    let time = Duration.millisecond(100)
    let socket = Socket(TCP,"www.baidu.com", 80)
    let socketC = SocketC(socket)
    let request: okhttp.Request = okhttp.Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let req4cj =  request.toHttpRequest()
    var requestStream  = ByteArrayStream()
    req4cj.copyTo(requestStream)
    socketC.connect(time)
    socketC.write(requestStream.readToEnd(),time)
    var readBuf: Array<Byte> = Array<Byte>(1024, item: 0)
    socketC.read(readBuf,time)
    socketC.close()
}