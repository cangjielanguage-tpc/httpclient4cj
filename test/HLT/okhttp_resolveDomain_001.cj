// 3rd_party_lib:httpclient4cj/build/httpclient4cj

import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.fs.*
import std.sync.sleep

@Test
public class okhttp_resolveDomain_001 {
    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "hello".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhttp_resolveDomain_001(): Unit {
        serve()
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