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
from std import sync.sleep

var port: UInt16 = 0

main() {
    serve()
    let myInterceptor = MyInterceptor()
    let client: HttpClient= HttpClient.builder().addInterceptor(myInterceptor).build()
    myInterceptor.setClient(client)

    for(i in 0..3) {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://127.0.0.1:${port}/1234")
        .tag("test${i}")
        .build()
        client.newCall(request).enqueue(MyCallbacks())
    }

}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println("${e.message}")
    }
    public func onResponse(call: Call,  response: httpclient4cj.Response): Unit{
        println("success")
    }
}


class MyInterceptor<: Interceptor {
    var client: Option<HttpClient> = Option<HttpClient>.None
     public func setClient(client: HttpClient) {
        this.client = client
     }

     public func intercept(chain: Chain): httpclient4cj.Response {
        let dispatcher = client.getOrThrow().getDispatcher()
        let run = dispatcher.runningCalls()
        println(run.size)
        for(i in run) {
            if (i.getRequest().getTag("test1").tag != "") {
                i.cancel()
            }

        }
        println("end ========")
        return chain.proceed(chain.getRequest())
    }
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder.new().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        sleep(3*Duration.second)
        let resp = "Hello from /red".toUtf8Array()
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}


var num = Int64(0)
