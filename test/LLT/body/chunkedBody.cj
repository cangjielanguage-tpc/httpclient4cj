// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import collection.*
from net import http.*
from std import io.*
from std import socket.*
from std import sync.sleep
from std import time.*

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(Duration.second)
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("POST", body: MyRequestBody())
                                    .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.toString())
    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
         return 0

    }
}

func serve(){
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


class MyRequestBody <:RequestBody {
    public func contentType(): Option<MediaType> {
        return MediaType.parse("application/json")
    }

    public func getContentLength(): Int64 {
        return -1
    }

    public func writeTo(sink: Sink): Unit {
        sink.write("hello".toUtf8Array())
        sink.write("world".toUtf8Array())
    }

    public func get(): InputStream {
        return ByteArrayStream()

    }

}