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
main() {
    serve()
    let formBody = FormBody.builder()
                .add("username", "admin")
                .add("password", "123456")
                .add("host","%6D")
                .build()
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .method("PROPPATCH", body: formBody)
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    return 0
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", {httpContext =>
        let resp = "Hello from /red".toArray()
        let  s = "http://127.0.0.1:${port}/1234"
        httpContext.responseBuilder.status(307)
        httpContext.responseBuilder.header("Location", s)
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}