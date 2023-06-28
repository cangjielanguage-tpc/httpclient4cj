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
//重定向401,客户端需要进行鉴权处理，默认不处理，此时直接返回错误的响应结果
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
    let response: okhttp.Response
    try{
        response = call.execute()
    }catch (e: Exception) {
        return 0
    }
    if (response.isSuccess()) {
        return 1
    } else {
        return 0
    }
}

func serve(){
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.writeStatusCode(401)
        rws.header().set("Location","http://127.0.0.1:${port}/1234")
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}