// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.sync.sleep
import std.unittest.*
import std.unittest.testmacro.*

var port: UInt16 = 0
main() {
    serve()
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient = HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    println(response.toString())
    @Assert(response.toString().contains("Internal Server Error"))
    return 0
}

func serve() {
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234",
        {
        httpContext =>
        println(1.1)
        httpContext.responseBuilder.header("", "test")
        println(1.2)
        return
    })
    spawn {server.serve()}
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}
