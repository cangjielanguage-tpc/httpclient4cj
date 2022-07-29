// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import socket.*
from net import http.*

main () {
    Util()
    let socket = Socket(TCP,"www.baidu.com", 80)
    socket.connect()
    Util.closeQuietly(socket)
    Util.closeQuietly(Option<Socket>.None)
    return 0
}

