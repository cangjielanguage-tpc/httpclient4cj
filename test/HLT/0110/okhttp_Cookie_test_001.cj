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
from std import collection.*

@Test
public class okhttp_Cookie_Test_001{
    
    // public static func parse(url: URL, setCookie: String): Option<Cookie> 合法url
    @TestCase
    func okhttp_Cookie_Test_001(): Unit {
        var cookie_01:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        // 保证几个关键字都存在, 可以用其他格式, 保存时会自动改成规范的格式(如cookie_01)
        var cookie_test_01:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com"
        let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_01)
        @Expect(cookieUtil.getOrThrow().toString(), cookie_01)
        let cookieUtil01 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_test_01)
        @Expect(cookieUtil01.getOrThrow().toString(), cookie_01)

        var cookie_02:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Expires=Fri, 13 Dec 2024 08:44:48 UTC"
        let cookieUtil2 = CookieUtil.parse(URL.parse("http://[::180.101.49.13]/foo/bar/baz"), cookie_02)
        @Expect(cookieUtil2.getOrThrow().toString(), cookie_02)

        var cookie_03:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        let cookieUtil3 = CookieUtil.parse(URL.parse("http://[Ff00::b465:310d]/foo/bar/baz"), cookie_03)
        @Expect(cookieUtil3.getOrThrow().toString(),cookie_03)
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> 非法url
    @TestCase
    func okhttp_Cookie_Test_002(): Unit {
        try {
            var cookie_01:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
            let cookieUtil = CookieUtil.parse(URL.parse("http://www.nisohbfahoiaf.com/"), cookie_01)
            @Expect(cookieUtil.getOrThrow().toString(), cookie_01)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            var cookie_02:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
            let cookieUtil2 = CookieUtil.parse(URL.parse("http://[FF00::b465:310d]/foo/bar/baz"), cookie_02)
            @Expect(cookieUtil2.getOrThrow().toString(), cookie_02)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            var cookie_03:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=baidu.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
            let cookieUtil3 = CookieUtil.parse(URL.parse("http://www.nisohbfahoiaf.com/"), cookie_03)
            @Expect(cookieUtil3.getOrThrow().toString(), cookie_03)
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 符合格式的普通字母/数字
    @TestCase
    func okhttp_Cookie_Test_003(): Unit {
        var cookie_01:String = "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_01)
        @Expect(cookieUtil.getOrThrow().toString(), cookie_01)

        var cookie_02:String = "_zap=ajdp--sjwojeoai; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        let cookieUtil2 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_02)
        @Expect(cookieUtil2.getOrThrow().toString(), cookie_02)
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 无格式字母/数字
    @TestCase
    func okhttp_Cookie_Test_004(): Unit {
        // try {
        //     let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
        //         "asdhoiqwhkhbcd8769spaiouorh43ahfpajdpajpda345hfhogfiygpsaja14685nffjho")
        //     println(cookieUtil.getOrThrow().toString())
        // } catch (e: Exception) {
        //     @Expect(e is NoneValueException)
        // }

        // try { //年份最大值是2261 超过这个数字会报超出int64的范围
        //     let cookieUtil2 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
        //         "_zap=ajdpoia[pnwirpo]; path=/hofgu0weja; expires=, 30 Dec 2262 20:44:48 GMT; domain=.example.com")
        //     println(cookieUtil2.getOrThrow().toString())
        // }catch (e: Exception) {
        //     @Expect(e is OverflowException)
        // }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 中文
    @TestCase
    func okhttp_Cookie_Test_005(): Unit {
        var flag = false
        try {
            let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
                "中文=cookie; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println(cookieUtil.getOrThrow().toString())
        } catch (e: Exception) {
            if (e is NoneValueException) {
                flag = true
            }
        }
        @Expect(flag)

        flag = false
        try {
            let cookieUtil2 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
                "key=中文; path=/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println(cookieUtil2.getOrThrow().toString())
        } catch (e: Exception) {
            if (e is NoneValueException) {
                flag = true
            }
        }
        @Expect(flag)
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 1k长度
    @TestCase
    func okhttp_Cookie_Test_006(): Unit {
        var tagString_a = StringBuilder('a', 1024).toString()
        var cookie_01:String = "${tagString_a}=${tagString_a}; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_01)
        @Expect(cookieUtil.getOrThrow().toString(), cookie_01)
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 4k长度以上
    // 目前查询到的资料, cookie 是有大小限制的, 大多数浏览器支持最大为 4096 字节的 Cookie, 如果 cookie 字符串的长度超过最大限制, 则该属性将返回空字符串
    // 不确定是否需要进一步优化
    @TestCase
    func okhttp_Cookie_Test_007(): Unit { 
        var tagString_a = StringBuilder('a', 5000).toString()
        var cookie_01:String = "${tagString_a}=${tagString_a}; Path=/foo/bar; Domain=example.com; Expires=Sun, 13 Oct 2024 08:44:48 UTC"
        let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_01)
        @Expect(cookieUtil.getOrThrow().toString(), cookie_01)
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie ""
    @TestCase
    func okhttp_Cookie_Test_008(): Unit {
        try {
            let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), "")
            @Expect(cookieUtil.getOrThrow().toString(), "")
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }

    // public static func parse(url: URL, setCookie: String): Option<Cookie> setCookie 特殊符号(cookie 标准库中的toString() 方法有问题, 有正则允许范围外的符号时, 会直接返回空)
    @TestCase
    func okhttp_Cookie_Test_009(): Unit {
        try {
            var cookie_01:String = "6676#@%$%^$%^=!@@@%%^**:<K{}2423; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com"
            let cookieUtil = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_01)
            println("cookieUtil")
            match (cookieUtil) { //打印cookie 的内容是存在的
                case Some(v) => 
                    @Expect(v.name, "6676#@%$%^$%^")
                    @Expect(v.value, "!@@@%%^**:<K{}2423")
                    @Expect(v.path, "/foo/bar")
                    @Expect(v.domain, "example.com")
                case None => println()
            }
            // 使用toString 会返回空
            //@Expect(cookieUtil2.getOrThrow().toString(), "")
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }

        try {
            var cookie_02:String = "sdf~!#$%^&*()_+{}|:<>?/*-+; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com"
            let cookieUtil2 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), cookie_02)
            println("cookieUtil2")
            match (cookieUtil2) { 
                case Some(v) => 
                    @Expect(v.name, "")
                    @Expect(v.value, "")
                    @Expect(v.path, "/foo/bar")
                    @Expect(v.domain, "example.com")
                case None => println()
            }
        } catch (e: Exception) { //key=value 这个参数可以不加 添加的话key不能为空 必须有=;
            @Expect(e is IllegalArgumentException)
        }

        // 源码中正则的检测是同一个方法, 但实际效果不一样? 确定为cookie 标准库中的toString() 方法的问题,单独打印每个参数值是正确的
        try {
            let cookieUtil3 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
                "key=!,.?[sdf](sdf){sdf}<sdf>; path=/foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil3")
            match (cookieUtil3) { 
                case Some(v) => 
                    @Expect(v.name, "key")
                    @Expect(v.value, "!,.?[sdf](sdf){sdf}<sdf>")
                    @Expect(v.path, "/foo/bar")
                    @Expect(v.domain, "example.com")
                case None => println()
            }
            println(cookieUtil3.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
        try {
            let cookieUtil4 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"), 
                "<sdf>[sdf](sdf){sdf}=abc; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
            println("cookieUtil4")
            match (cookieUtil4) { 
                case Some(v) => 
                    @Expect(v.name, "<sdf>[sdf](sdf){sdf}")
                    @Expect(v.value, "abc")
                    @Expect(v.path, "/foo/bar")
                    @Expect(v.domain, "example.com")
                case None => println()
            }
            println(cookieUtil4.getOrThrow().toString())
        } catch (e: Exception) {
            @Expect(e is NoneValueException)
        }
    }
}

