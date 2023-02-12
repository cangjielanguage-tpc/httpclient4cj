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
public class okhttp_Cookie_Test_001{

    // public static func parse(url: URL, setCookie: String): Option<Cookie> 合法url
    @TestCase
    func okhttp_Cookie_Test_001(): Unit {
        let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
        println(cookieUtil.getOrThrow().toString())

        let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://[::180.101.49.13]/foo/bar/baz"),
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 dec 2024 08:44:48 GMT; domain=::180.101.49.13")
        println(cookieUtil2.getOrThrow().toString())

        let cookieUtil3 = CookieUtil.parse(URL.parseRequestURI("http://[Ff00::b465:310d]/foo/bar/baz"),
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=Ff00::b465:310d")
        println(cookieUtil3.getOrThrow().toString())
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> 非法url
    @TestCase
    func okhttp_Cookie_Test_002(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://www.nisohbfahoiaf.com/"), 
                "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://[FF00::b465:310d]/foo/bar/baz"),
                "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=fFee::b465:310d")
            println(cookieUtil2.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 符合格式的普通字母/数字
    @TestCase
    func okhttp_Cookie_Test_003(): Unit {
        let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
        println(cookieUtil.getOrThrow().toString())

        let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
            "_zap=ajdp;oia[pnwirpo]; path=hofgu0weja; expires=asdafgg, 13 Oct 2024 08:44:48 GMT; domain=ssdfrgrg")
        println(cookieUtil2.getOrThrow().toString())
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 无格式字母/数字
    @TestCase
    func okhttp_Cookie_Test_004(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "asdhoiqwhkhbcd8769spaiouorh43ahfpajdpajpda345hfhogfiygpsaja14685nffjho")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try { //年份最大值是2261 超过这个数字会报超出int64的范围
            let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "_zap=ajdpoia[pnwirpo]; path=/hofgu0weja; expires=, 30 Dec 2262 20:44:48 GMT; domain=.example.com")
            println(cookieUtil2.getOrThrow().toString())
        }catch (e: Exception) {
            @Expect(e is OverflowException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 中文
    @TestCase
    func okhttp_Cookie_Test_005(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "中文=cookie; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "key=中文; path=/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println(cookieUtil2.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 1k长度
    @TestCase
    func okhttp_Cookie_Test_006(): Unit {
        var tagString_a = StringBuilder('a', 1024).toString()
        let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
            "${tagString_a}=${tagString_a}; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
        println(cookieUtil.getOrThrow().toString())
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 4k长度以上
    // 目前查询到的资料, cookie 是有大小限制的, 大多数浏览器支持最大为 4096 字节的 Cookie, 如果 cookie 字符串的长度超过最大限制, 则该属性将返回空字符串
    @TestCase
    func okhttp_Cookie_Test_007(): Unit { 
        var tagString_a = StringBuilder('a', 5000).toString()
        let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
            "name=${tagString_a}; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
        println(cookieUtil.getOrThrow().toString())
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie ""
    @TestCase
    func okhttp_Cookie_Test_008(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), "")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 特殊符号(有正则校验 多试验几种特殊符号组合)
    @TestCase
    func okhttp_Cookie_Test_009(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "6676#@%$%^$%^=!@@@%%^**):<K{}2423; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            let cookieUtil2 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "sdf~!#$%^&*()_+{}|:<>?/*-+; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil2")
            println(cookieUtil2.getOrThrow().toString())
        } catch (e: Exception) { //key=value 这个参数可以不加 添加的话key不能为空 必须有=和;
            @Expect(e is IllegalArgumentException)
        }

        try {
            let cookieUtil3 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "sdf~!#$%^&*()_+{}|:<>?/*-+=sdf~!#$%^&*()_+{}|:<>?/*-+; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil3")
            println(cookieUtil3.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        // 源码中正则的检测是同一个方法, 但实际效果不一样? 确定为cookie 标准库中的toString() 方法的问题
        try {
            let cookieUtil4 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "key=!,.?[sdf](sdf){sdf}<sdf>; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil4")
            println(cookieUtil4.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
        try {
            let cookieUtil5 = CookieUtil.parse(URL.parseRequestURI("http://example.com/foo/bar/baz"), 
                "<sdf>[sdf](sdf){sdf}=abc; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil5")
            println(cookieUtil5.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }
}

