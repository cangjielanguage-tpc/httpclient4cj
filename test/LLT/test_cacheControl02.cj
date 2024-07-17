// DEPENDENCE: ./z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*

import net.http.*
import std.io.*
import std.time.*
import std.socket.*
import std.sync.sleep

var port: UInt16 = 0
main() {
    serve()

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/index")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    return 0
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/index", { httpContext =>
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}