// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj

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

@Test
public class okhttp_resolveDomain_001 {
    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "hello".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }

    @TestCase
    func okhttp_resolveDomain_001(): Unit {
        spawn {
            serve()
        }
        sleep(Duration.second)
        let url = URL.parse("http://127.0.0.1:${port}/1234")
        var socketHost = url.hostName
        let arr = resolveDomain(TCP, socketHost)

        println("resolveDomain.size:${arr.size}")
        @Assert(arr.size,1)
        var kv = arr.get(0).getOrThrow()
        println("SocketAddressKind:${kv[0]}")
        @Assert(kv[0].toString(),"ipv4")
        println("Host:${kv[1]}")
        @Assert(kv[1].toString(),"[127, 0, 0, 1]")
    }
}