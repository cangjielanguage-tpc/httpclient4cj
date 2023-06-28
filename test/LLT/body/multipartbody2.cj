// DEPENDENCE: ./body.text
// DEPENDENCE: ./body2.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*
from net import http.*
from std import io.*
from std import socket.*
from std import fs.*
from std import sync.sleep
from std import time.*

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(Duration.second)
    let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))
    let body2 = RealRequestBody.create(MediaType.get("application/json"),File("./body2.text",OpenOption.Open(true,false)))
    let mu = MultipartBody.builder().
    addFormDataPart("name", "lyk").
    addFormDataPart("age", "18").
    addFormDataPart("file1", "body.text", body).
    addFormDataPart("file2", "body2.text", body2).build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("POST", body: mu)
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.toString())
    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
         return 0
    }
}

func serve() {
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        println(String.fromUtf8(req.readToEnd()))
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}
