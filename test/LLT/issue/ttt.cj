// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
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
    spawn {
        serve()
    }
    sleep(Duration.second)

    var client: OkHttpClient = OkHttpClient.builder().build()
    var request: okhttp.Request
    var response: okhttp.Response

    var index:Int64
    // test case 4：enqueue请求 访问仓颉server端 http://127.0.0.1:${port}/1234
    request = okhttp.Request.builder()
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

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        print("failed ")
    }
    public func onResponse(call: Call,  response: okhttp.Response): Unit{
        i.fetchAdd(1)
        print("${i.load() }")
    }
}