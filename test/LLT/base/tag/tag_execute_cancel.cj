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
import std.sync.sleep

var port: UInt16 = 0

main() {
    serve()
    let myInterceptor = MyInterceptor()
    let client: HttpClient= HttpClient.builder().addInterceptor(myInterceptor).build()
    myInterceptor.setClient(client)

    try{
        for(i in 0..10) {
            let request: httpclient4cj.Request = httpclient4cj.Request.builder()
            .url("http://127.0.0.1:${port}/1234")
            .tag("test${i}")
            .build()
            client.newCall(request).execute()
        }
    }catch (e: Exception) {
        return 0
    }
    return 1
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
                println("hasCancel")
                i.cancel()
                 println("hasCancel2")
            } else {
                println("noCancel")
            }
        }
        println("end ========")
        return chain.proceed(chain.getRequest())
    }
}

func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        sleep(3*Duration.second)
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}


var num = Int64(0)
