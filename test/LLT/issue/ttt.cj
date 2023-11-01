// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from std import time.*
from std import socket.*
from std import sync.*

 var times:Int64 = 50
 var end:Int64 = 0
 var port: UInt16 = 0
 var i:AtomicInt64 = AtomicInt64(0)


main (){
    serve()

    var client: HttpClient = HttpClient.builder().build()
    var request: httpclient4cj.Request
    var response: httpclient4cj.Response

    var index:Int64
    // test case 4：enqueue请求 访问仓颉server端 http://127.0.0.1:${port}/1234
    request = httpclient4cj.Request.builder()
                        .url("http://127.0.0.1:${port}/1234")
                        .build()
    index = 0
    while(index < times){
        index++;
        client.newCall(request).enqueue(MyCallbacks())
    }
    sleep(Duration.second*30)
}

func serve() {

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

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        print("failed ")
    }
    public func onResponse(call: Call,  response: httpclient4cj.Response): Unit{
        i.fetchAdd(1)
        print("${i.load() }")
    }
}