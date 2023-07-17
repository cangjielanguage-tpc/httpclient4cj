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
    spawn {
        serve()
    }
    sleep(Duration.second)
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
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}



