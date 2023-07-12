// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import fs.*
from std import sync.sleep
from std import os.posix.*

@Test
public class okhttp_Request_method_010{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_Request_method_010(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)
    var f = `open`("log.txt", O_RDWR | O_CREAT | O_TRUNC)
    // 重定向到 log.txt 文件
    var f1 = dup(1)
    dup2(f, 1)

    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("abc")
                                    .build()
    var call = client.newCall(request)
    call.execute()

    print("-----------log flush----------\n ", flush:true)
    sleep(Duration.second*1)

    // 恢复到标准输出（屏幕)
    dup2(f1, 1)
    close(f1)

    var filename = "log.txt"
    chmod(filename,777)
    var bytearry = File.readFrom(filename)
    var str = String.fromUtf8(bytearry)
    print("str ${str}")
    @Assert(str.contains("net/http: invalid method:abc"), true)

    }
}


