// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

from net import http.*
from std import io.*
from std import time.*
from std import socket.*
from std import sync.sleep

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(Duration.second)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    let call = client.newCall(request)
    let response: okhttp.Response = call.execute()
    return 0
}

func serve(){
    let hd = http.Route()
    hd.handle("/index", { rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}