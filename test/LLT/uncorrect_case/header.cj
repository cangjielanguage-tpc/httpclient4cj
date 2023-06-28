// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(Duration.second)
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)
    try{
        let response: okhttp.Response = call.execute()
    }catch (e: Exception) {
        return 0
    }
    return 1
}

func serve(){
    let hd = http.Route()
    hd.handle("/1234", {rws: http.ResponseWriteStream, req: http.Request =>
        rws.header().set("", "test")
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}