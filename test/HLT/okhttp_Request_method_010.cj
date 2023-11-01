// 3rd_party_lib:httpclient4cj/build/httpclient4cj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
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
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_Request_method_010(): Unit {
        serve()
        var f = `open`("log.txt", O_RDWR | O_CREAT | O_TRUNC)
        // 重定向到 log.txt 文件
        var f1 = dup(1)
        dup2(f, 1)

        let client: HttpClient= HttpClient.builder().build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url("http://127.0.0.1:${port}/1234")
                                        .method("a:bc")
                                        .build()
        var call = client.newCall(request)
        let a = call.execute()
        println(a.toString())

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
        @Assert(str.contains("Invalid request method: a:bc"), true)

    }
}


