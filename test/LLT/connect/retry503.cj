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

var port: UInt16 = 0

main() {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: OkHttpClient= OkHttpClient.builder().retryOnConnectionFailure(false).build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)
    try{
        let response: okhttp.Response = call.execute()
    }catch (e: Exception) {
        println(e.message)
        return 1
    }
    return 0
}


func serve(){
    let hd = http.Route()
    hd.handle("/1234", {rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.writeStatusCode(503)
        rws.header().set("Retry-After", "0")
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}