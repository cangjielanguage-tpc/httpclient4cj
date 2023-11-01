from net import http.ServerBuilder
from std import socket.{TcpServerSocket, SocketAddress}
from std import sync.sleep
from std import time.Duration

func serve() {
    let serverSocket = TcpServerSocket(bindAt: 50060)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/", {
        httpContext =>
        httpContext.responseBuilder.body("Hello".toArray())
        return
    })
    spawn {server.serve()}
    sleep(Duration.second)
    serverSocket.localAddress.port
}
let port: UInt16 = serve()
