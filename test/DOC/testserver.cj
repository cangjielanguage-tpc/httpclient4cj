internal import net.http.ServerBuilder
internal import std.socket.{TcpServerSocket, SocketAddress}
internal import std.sync.sleep
internal import std.time.Duration

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
