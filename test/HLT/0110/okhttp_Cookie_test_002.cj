// 3rd_party_lib:okhttp/build/okhttp

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
from std import collection.*

@Test
public class okhttp_Cookie_Test_002{

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> 合法url
    @TestCase
    func okhttp_Cookie_Test_010(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        let header: http.Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)

        let cookieUtil = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        @Expect(cookieUtil.get(0).getOrThrow().toString(), cookieString_01)
        @Expect(cookieUtil.get(1).getOrThrow().toString(), cookieString_02)

        let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://[::180.101.49.13]/foo/bar/baz"), header)
        println("cookieUtil2")
        @Expect(cookieUtil.get(0).getOrThrow().toString(), cookieString_01)
        @Expect(cookieUtil.get(1).getOrThrow().toString(), cookieString_02)

        let cookieUtil3 = CookieUtil.parse(URL.parseRequestURI("http://[Ff00::b465:310d]/foo/bar/baz"), header)
        println("cookieUtil3")
        @Expect(cookieUtil3.get(0).getOrThrow().toString(), cookieString_01)
        @Expect(cookieUtil3.get(1).getOrThrow().toString(), cookieString_02)
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> 非法url
    @TestCase
    func okhttp_Cookie_Test_011(): Unit {
        var cookieString_01 = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        var cookieString_02 = "_zap=aaaa-bbbb; Path=/kkk/ddd; Domain=example.com; Expires=Mon, 25 Oct 2055 16:02:05 UTC"
        let header: http.Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://www.nisohbfahoiaf.com/"), header)
            @Expect(cookieUtil.get(0).getOrThrow().toString(), cookieString_01)
            @Expect(cookieUtil.get(1).getOrThrow().toString(), cookieString_02)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://[FF00::b465:310d]/foo/bar/baz"), header)
            @Expect(cookieUtil.get(0).getOrThrow().toString(), cookieString_01)
            @Expect(cookieUtil.get(1).getOrThrow().toString(), cookieString_02)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 不包含cookie
    @TestCase
    func okhttp_Cookie_Test_012(): Unit {
        let url : URL = URL.parse("http://127.0.0.1:1105/1234")
        let header: http.Header = Header()
        header.add("content-type", "application/json") 
        header.add("content-type2", "application2/json")
        try {
            let cookieUtil = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header)
            println("cookieUtil")
            @Expect(cookieUtil.get(0).getOrThrow().toString(), "")
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
        
        let header_01: http.Header = Header()
        header_01.add("Set-Cookie", cookieString_01) 
        let cookieUtil_01 = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header_01)
        println("cookieUtil_01")
        @Expect(cookieUtil_01.get(0).getOrThrow().toString(), cookieString_01)

        let header_02: http.Header = Header()
        header_02.add("Set-Cookie", cookieString_02) 
        let cookieUtil_02 = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header_02)
        println("cookieUtil_02")
        @Expect(cookieUtil_02.get(0).getOrThrow().toString(), cookieString_02)

        let header_03: http.Header = Header()
        header_03.add("Set-Cookie", cookieString_03)
        try {
            let cookieUtil_03 = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header_03)
            println("cookieUtil_03")
            @Expect(cookieUtil_03.get(0).getOrThrow().toString(), cookieString_03)
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
        var cookieString_03 = "key=; Path=/iiiiiii; Domain=example.com; Expires=Sun, 06 Oct 2007 23:44:50 UTC"

        let header: http.Header = Header()
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        header.add("Set-Cookie", cookieString_03)
        header.add("Set-Cookie", cookieString_01) 
        header.add("Set-Cookie", cookieString_02)
        header.add("Set-Cookie", cookieString_03)

        let cookieUtil = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        @Expect(cookieUtil.get(0).getOrThrow().toString(), cookieString_01)
        @Expect(cookieUtil.get(1).getOrThrow().toString(), cookieString_02)
        @Expect(cookieUtil.get(2).getOrThrow().toString(), cookieString_03)
        @Expect(cookieUtil.get(3).getOrThrow().toString(), cookieString_01)
        @Expect(cookieUtil.get(4).getOrThrow().toString(), cookieString_02)
        @Expect(cookieUtil.get(5).getOrThrow().toString(), cookieString_03)
    }

    // public static func parseAll(url: URL, headers: Header): ArrayList<Cookie> headers 没有任何内容
    @TestCase
    func okhttp_Cookie_Test_015(): Unit {
        let header: http.Header = Header()
        let cookieUtil = CookieUtil.parseAll(URL.parseRequestURI("http://example.com/foo/bar/baz"), header)
        println("cookieUtil")
        @Expect(cookieUtil.size, 0)
    }
}

