// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from net import http.*
from std import socket.*
from httpclient4cj import httpclient4cj.*
from std import io.*
from std import time.*

main() {
    let socket = TcpSocket("www.baidu.com", portTrans(80))
    let socketC = SocketC(socket)
    socketC.connect(Duration.millisecond * 10000)
    println(socket.isClosed())
}
