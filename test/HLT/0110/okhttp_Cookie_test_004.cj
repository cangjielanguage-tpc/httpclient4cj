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
from std import collection.*
from std import sync.sleep

@Test
public class okhttp_Cookie_Test_004{
    var port: UInt16 = 0
    
    // public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit cookies 不包含cookie
    // public func loadForRequest(url: URL): Array<Cookie>
    @TestCase
    func okhttp_Cookie_Test_018(): Unit {
        let url: URL = URL.parse("http://example.com/foo/bar/baz")
        let jar = getSimpleCookieJar()
        jar.saveFromResponse(url, [])
        let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
        let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(url)
        @Expect(loadCookies.size, 0) 
    }

    // public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit cookies 只有一个cookie
    // public func loadForRequest(url: URL): Array<Cookie>
    @TestCase
    func okhttp_Cookie_Test_019(): Unit {
        let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
        let jar = getSimpleCookieJar()
        jar.saveFromResponse(url, [Cookie("BD_HOME", "1")])
        let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
        let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(url)
        @Expect(loadCookies.size, 1) 
        @Expect(loadCookies[0].toSetCookieString(), "BD_HOME=1")

        jar.saveFromResponse(url, [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
        let client2: HttpClient= HttpClient.builder().cookieJar(jar).build()
        let loadCookies2: Array<Cookie> = client.getCookieJar().loadForRequest(url)
        @Expect(loadCookies2.size, 2) 
        @Expect(loadCookies2[1].toSetCookieString(), "BD_UPN=12314753")
    }

    // public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit cookies 包含多个cookie
    // public func loadForRequest(url: URL): Array<Cookie>
    @TestCase
    func okhttp_Cookie_Test_020(): Unit {
        var serverCookie_01 = "key=server-header-1; Path=/; Domain=127.0.0.1; Expires=Mon, 31 Dec 2260 23:59:59 UTC"
        var serverCookie_02 = "key=server-header-2; Path=/; Domain=127.0.0.1; Expires=Mon, 31 Dec 2260 23:59:59 UTC"

        let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
        let jar = getSimpleCookieJar()
        jar.saveFromResponse(url, [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
        let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
        let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(url)
        @Expect(loadCookies.size, 2) 
        @Expect(loadCookies[1].toSetCookieString(), "BD_UPN=12314753")
        @Expect(loadCookies[0].toSetCookieString(), "BD_HOME=1")
    }

    // 构建 httpClientBuilder 时不设置 cookieJar 验证是否自动使用了 NoCookieJar
    @TestCase
    func okhttp_Cookie_Test_021(): Unit { //半手动用例, 在源码中加入了打印语句确认调用成功
        let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
        let client: HttpClient= HttpClient.builder().build()
        let jar = client.getCookieJar()
        let loadCookies: Array<Cookie> = jar.loadForRequest(url)
        @Expect(loadCookies.size, 0) 
    }


    func serve() {
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder.new().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toUtf8Array()
            httpContext.responseBuilder.body(resp)
            httpContext.responseBuilder.header("test", "test")
            httpContext.responseBuilder.header("Set-Cookie", "key=server-header-1;")
            httpContext.responseBuilder.header("Set-Cookie", "key=server-header-2;")
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

}

