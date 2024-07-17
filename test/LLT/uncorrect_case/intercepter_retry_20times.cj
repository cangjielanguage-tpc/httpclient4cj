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

var port: UInt16 = 0
//重定向次数超20次后，结束重定向并抛出异常
main() {
    serve()
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response
    try{
        response = call.execute()
    }catch (e: Exception) {
        return 0
    }
    if (response.isSuccess()) {
        return 1
    } else {
        return 0
    }
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.status(307)
        httpContext.responseBuilder.header("Location","http://127.0.0.1:${port}/1234")
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}