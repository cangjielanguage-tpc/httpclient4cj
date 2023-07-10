// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
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
    spawn {
        serve()
    }
    sleep(Duration.second)
    let myInterceptor = MyInterceptor()
    let client: OkHttpClient= OkHttpClient.builder().addInterceptor(myInterceptor).build()
    myInterceptor.setClient(client)

    try{
        for(i in 0..10) {
            let request: okhttp.Request = okhttp.Request.builder()
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
    var client: Option<OkHttpClient> = Option<OkHttpClient>.None
     public func setClient(client: OkHttpClient) {
        this.client = client
     }

     public func intercept(chain: Chain): okhttp.Response {
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
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        sleep(3*Duration.second)
        let resp = "Hello from /red".toUtf8Array()
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}


var num = Int64(0)
