// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import collection.*
from std import time.*
from std import runtime.*
from net import http.*
from std import socket.*
from std import io.*
from std import sync.*

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



