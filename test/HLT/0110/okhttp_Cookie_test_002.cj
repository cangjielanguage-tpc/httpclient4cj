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

@Test
public class okhttp_Cookie_Test_002{

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> 合法url
    @TestCase
    func okhttp_Cookie_Test_010(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        let header: Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)

        let cookieUtil = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), cookieString_01)
        expect(cookieUtil.get(1).getOrThrow().toSetCookieString(), cookieString_02)

        let cookieUtil2 = CookieUtil.parseAll(URL.parse("http://[::180.101.49.13]/foo/bar/baz"), header)
        println("cookieUtil2")
        expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), cookieString_01)
        expect(cookieUtil.get(1).getOrThrow().toSetCookieString(), cookieString_02)
    }
    
    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> 非法url
    @TestCase
    func okhttp_Cookie_Test_011(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        let header: Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        
        try {
            let cookieUtil = CookieUtil.parseAll(URL.parse("http://www.nisohbfahoiaf.com/"), header)
            expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), cookieString_01)
            expect(cookieUtil.get(1).getOrThrow().toSetCookieString(), cookieString_02)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            let cookieUtil2 = CookieUtil.parseAll(URL.parse("http://[FF00::b465:310d]/foo/bar/baz"), header)
            expect(cookieUtil2.get(0).getOrThrow().toSetCookieString(), cookieString_01)
            expect(cookieUtil2.get(1).getOrThrow().toSetCookieString(), cookieString_02)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 不包含cookie
    @TestCase
    func okhttp_Cookie_Test_012(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1105/1234")
        let header: Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type2", "application2/json")
        try {
            let cookieUtil = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header)
            println("cookieUtil")
            expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), "")
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 只有一个cookie 另外验证cookie 不符合格式的情况
    @TestCase
    func okhttp_Cookie_Test_013(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        var cookieString_03 = "=; Path=/iiiiiii; Domain=example.com; Expires=Sun, 06 Oct 2007 23:44:50 UTC"
        
        let header_01: Header = Header()
        header_01.add("Set-Cookie", cookieString_01) 
        let cookieUtil_01 = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header_01)
        println("cookieUtil_01")
        expect(cookieUtil_01.get(0).getOrThrow().toSetCookieString(), cookieString_01)

        let header_02: Header = Header()
        header_02.add("Set-Cookie", cookieString_02) 
        let cookieUtil_02 = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header_02)
        println("cookieUtil_02")
        expect(cookieUtil_02.get(0).getOrThrow().toSetCookieString(), cookieString_02)

        let header_03: Header = Header()
        header_03.add("Set-Cookie", cookieString_03)
        try {
            let cookieUtil_03 = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header_03)
            println("cookieUtil_03")
            expect(cookieUtil_03.get(0).getOrThrow().toSetCookieString(), cookieString_03)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
            println(e)
        }
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 包含多个cookie
    @TestCase
    func okhttp_Cookie_Test_014(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        var cookieString_03 = "key=; Path=/iiiiiii; Domain=example.com; Expires=Sat, 06 Oct 2007 23:44:50 UTC"

        let header: Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        header.add("Set-Cookie", cookieString_03)
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        header.add("Set-Cookie", cookieString_03)

        let cookieUtil = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        expect(cookieUtil.get(0).getOrThrow().toSetCookieString(), cookieString_01)
        expect(cookieUtil.get(1).getOrThrow().toSetCookieString(), cookieString_02)
        expect(cookieUtil.get(2).getOrThrow().toSetCookieString(), cookieString_03)
        expect(cookieUtil.get(3).getOrThrow().toSetCookieString(), cookieString_01)
        expect(cookieUtil.get(4).getOrThrow().toSetCookieString(), cookieString_02)
        expect(cookieUtil.get(5).getOrThrow().toSetCookieString(), cookieString_03)
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 没有任何内容
    @TestCase
    func okhttp_Cookie_Test_015(): Unit {
        let header: Header = Header()
        let cookieUtil = CookieUtil.parseAll(URL.parse("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        @Expect(cookieUtil.size, 0)
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
