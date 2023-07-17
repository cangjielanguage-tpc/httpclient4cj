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

@Test
public class okhttp_MediaType_test_001{

    // get 创建规范的 MediaType
    @TestCase
    func okhttp_MediaType_test_001(): Unit {
        var mediaType = MediaType.get("text/aaaaa; charset=utf-8")
        var get_type = mediaType.getType()
        var get_sub = mediaType.getSubtype()
        var get_charset = mediaType.getCharset()
        
        @Assert(get_type, "text")
        @Assert(get_sub, "aaaaa")
        @Assert(get_charset, "utf-8")
    }

    // parse 创建规范的 MediaType
    @TestCase
    func okhttp_MediaType_test_002(): Unit {
        var mediaType = MediaType.parse("text/xxxxx; charset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "text")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "utf-8")
            case None => 
                @Assert("未获取到MediaType", "")
        }
    }

    // get 创建 MediaType 没有";"区分
    @TestCase
    func okhttp_MediaType_test_003(): Unit {
        var flag = false
        try {
            var mediaType = MediaType.get("text/xxxxxcharset=utf-8")
        } catch (ex: Exception) {
            println(ex)
            flag = true
        }
        @Assert(flag)
    }

    // parse 创建 MediaType 没有";"区分
    @TestCase
    func okhttp_MediaType_test_004(): Unit {
        var mediaType = MediaType.parse("text/xxxxcharset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "text")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "utf-8")
            case None => 
                // 应该获取不到
                @Assert(true)
        }
    }

    // get 创建 MediaType 没有"charset"关键字
    @TestCase
    func okhttp_MediaType_test_005(): Unit {
        var flag = false
        try {
            var mediaType = MediaType.get("text/xxxxx; utf-8")
        } catch (ex: Exception) {
            println(ex)
            flag = true
        }
        @Assert(flag)
    }

    // parse 创建 MediaType 没有"charset"关键字
    @TestCase
    func okhttp_MediaType_test_006(): Unit {
        var mediaType = MediaType.parse("text/xxxx; =utf-8")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "text")
                @Assert(get_sub, "xxxx")
                @Assert(get_charset, "utf-8")
            case None => 
                // 应该获取不到
                @Assert(true)
        }
    }

    // get 创建 MediaType 有格式的非关键字
    @TestCase
    func okhttp_MediaType_test_007(): Unit {
        var mediaType = MediaType.get("xxxx/xxxxx; charset=xxxx")
        var get_type = mediaType.getType()
        var get_sub = mediaType.getSubtype()
        var get_charset = mediaType.getCharset()
        
        @Assert(get_type, "xxxx")
        @Assert(get_sub, "xxxxx")
        @Assert(get_charset, "xxxx")
    }

    // parse 创建 MediaType 有格式的非关键字
    @TestCase
    func okhttp_MediaType_test_008(): Unit {
        var mediaType = MediaType.parse("xxxx/xxxxx; charset=xxxx")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()  
                @Assert(get_type, "xxxx")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "xxxx")
            case None => 
                @Assert("未获取到MediaType", "")
        }
    }

    // get 创建 MediaType 有格式的非关键字
    @TestCase
    func okhttp_MediaType_test_009(): Unit {
        var mediaType = MediaType.get("xxxx/xxxxx; xxxx=xxxx")
        var get_type = mediaType.getType()
        var get_sub = mediaType.getSubtype()
        var get_charset = mediaType.getCharset()
        
        @Assert(get_type, "xxxx")
        @Assert(get_sub, "xxxxx")
        @Assert(get_charset, "")
    }

    // parse 创建 MediaType 有格式的非关键字
    @TestCase
    func okhttp_MediaType_test_010(): Unit {
        var mediaType = MediaType.parse("xxxx/xxxxx; xxxx=xxxx")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()  
                @Assert(get_type, "xxxx")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "")
            case None => 
                @Assert("未获取到MediaType", "")
        }
    }
}