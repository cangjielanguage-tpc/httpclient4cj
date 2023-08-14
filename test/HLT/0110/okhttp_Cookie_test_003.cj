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
public class okhttp_Cookie_Test_003{
    var port: UInt16 = 0

    // public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit url 合法地址
    // public func loadForRequest(url: URL): Array<Cookie>
    @TestCase
    func okhttp_Cookie_Test_016(): Unit {
        var serverCookie_01 = "key=server-header-1; Path=/; Domain=127.0.0.1; Expires=Mon, 31 Dec 2260 23:59:59 UTC"
        var serverCookie_02 = "key=server-header-2; Path=/; Domain=127.0.0.1; Expires=Mon, 31 Dec 2260 23:59:59 UTC"
        serve()
        let url: URL = URL.parse("http://127.0.0.1:${port}/1234")

        let jar = getSimpleCookieJar()
        jar.saveFromResponse(url, [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
        let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .url(url)
                                        .build()
        let call = client.newCall(request)
        try{
            let response: httpclient4cj.Response = call.execute()
            let header: Header = response.getHeaders()
            let cookieUtil = CookieUtil.parseAll(url, header)
            println("cookieUtil")
            @Expect(cookieUtil.size, 2)
            expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), serverCookie_01)
            expect(cookieUtil.get(1).getOrThrow().toSetCookieString(), serverCookie_02)
            let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(url)
            @Expect(loadCookies.size, 2) 
            // 应该是标准库的添加Cookie 的顺序没有规定,目前是最后一个添加的最先读取到
            // Cookie 没有getOrThrow()方法???
            expect(loadCookies[0].toSetCookieString(), "BD_UPN=12314753")
            expect(loadCookies[1].toSetCookieString(), "BD_HOME=1")
        } catch (e: Exception) {
            println(e)
        }
    }

    // public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit url 非法地址
    // public func loadForRequest(url: URL): Array<Cookie>
    @TestCase
    func okhttp_Cookie_Test_017(): Unit {
        let url: URL = URL.parse("http://www.nisohbfahoiaf.com/")
        try {
            let jar = getSimpleCookieJar()
            jar.saveFromResponse(url, [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
            let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
            let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                            .url(url)
                                            .build()
            let call = client.newCall(request)
            let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(url)
            @Expect(loadCookies.size, 2) 
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
        
        try {
            let jar = getSimpleCookieJar()
            jar.saveFromResponse(URL.parse("http://example.com/foo/bar/baz"), [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
            let client: HttpClient= HttpClient.builder().cookieJar(jar).build()
            let loadCookies: Array<Cookie> = client.getCookieJar().loadForRequest(URL.parse("http://www.nisohbfahoiaf.com/"))
            @Expect(loadCookies.size, 0) 
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
        
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

func expect(c: String, s: String): Unit {
    let map = HashMap<String, String>()
    for (str in c.split(';')) {
        let kv = str.split('=')
        map.put(kv[0].trimAscii(), kv[1].trimAscii())
    }
    for (str in s.split(';')) {
        let kv = str.split('=')
        @Expect(map[kv[0].trimAscii()], kv[1].trimAscii())
        map.remove(kv[0].trimAscii())
    }
    @Expect(map.size, 0)
}
