// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
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
    let client: HttpClient= HttpClient.builder().retryOnConnectionFailure(false).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)
    try{
        let response: httpclient4cj.Response = call.execute()
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
        rws.header().set("Retry-After", "llllll")
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}