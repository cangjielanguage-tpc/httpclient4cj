// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from net import http.*
from std import socket.*
from httpclient4cj import httpclient4cj.*
from std import io.*
from std import time.*
main() {
    let socket = Socket(TCP,"www.baidu.com", 80)
    let socketC = SocketC(socket)
    socketC.connect(Duration.millisecond*10000)
    println(socket.isClosed())
}
