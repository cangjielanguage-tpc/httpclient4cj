// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*
import std.time.*
import std.runtime.*
import net.http.*
import std.socket.*
import std.io.*
import std.sync.*

var port: UInt16 = 0
var num = Int64(0)

main() {
    serve()
    let client: HttpClient= HttpClient.builder()//.addNetworkInterceptor(MyInterceptor1())
                                        .build()
    client.getDispatcher().setIdleCallback( { => println("===================di idle======================")})
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .build()

    let response: httpclient4cj.Response = client.newCall(request).execute()
     println(client.getDispatcher().runningCallsCount())
    // sleep(Duration.second*5)
     println("num = ${num}")
}


func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}



