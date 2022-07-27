// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from net import http.*
from std import socket.*

main() {
    let socket = Socket(TCP,"www.baidu.com", 80)
    socket.connect()
}