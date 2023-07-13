// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj
// data_file:body.text

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
from std import collection.*

@Test
public class okhttp_MediaType_test_003{

    // get 创建 MediaType 使用""
    @TestCase
    func okhttp_MediaType_test_023(): Unit {
        try {
            var mediaType = MediaType.get("")
        } catch (ex: Exception) {
            println(ex)
        }
    }

    // parse 创建 MediaType 使用""
    @TestCase
    func okhttp_MediaType_test_024(): Unit {
        var mediaType = MediaType.parse("")
        match (mediaType) {
            case Some(contentType) =>
                println(contentType)
            case None => 
                println("None")
        }
    }

    // get 创建 MediaType 超长字符
    @TestCase
    func okhttp_MediaType_test_025(): Unit {
        var tagString_a = StringBuilder('a', 512).toString()
        var tagString_b = StringBuilder('b', 512).toString()
        var mediaType = MediaType.get("${tagString_a}/${tagString_b}; charset=utf-8")
        var get_type = mediaType.getType()
        var get_sub = mediaType.getSubtype()
        var get_charset = mediaType.getCharset()
        
        @Assert(get_type, tagString_a)
        @Assert(get_sub, tagString_b)
        @Assert(get_charset, "utf-8")
    }

    // parse 创建 MediaType 超长字符
    @TestCase
    func okhttp_MediaType_test_026(): Unit {
        var tagString_a = StringBuilder('a', 512).toString()
        var tagString_b = StringBuilder('b', 512).toString()
        var mediaType = MediaType.parse("${tagString_a}/${tagString_b}; charset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, tagString_a)
                @Assert(get_sub, tagString_b)
                @Assert(get_charset, "utf-8")
            case None => 
                println("None")
        }
    }

    // FormBody 的contentType 方法
    @TestCase
    func okhttp_MediaType_FormBody_test_027(): Unit {
        var formBody = FormBody.builder()
                .add("username", "admin")
                .add("password", "123456")
                .build()
        var input = formBody.get()
        var arr = Array<Byte>(input.length, item:0)
        input.read(arr)
        var inputString = String.fromUtf8(arr)
        @Assert(inputString, "username=admin&password=123456")
        var contentType = formBody.contentType().getOrThrow().toString()
        @Assert(contentType, "application/x-www-form-urlencoded")
    }

    // 空的 FormBody 的contentType 方法
    @TestCase
    func okhttp_MediaType_FormBody_test_028(): Unit {
        var formBody = FormBody.builder().build()
        var input = formBody.get()
        var arr = Array<Byte>(input.length, item:0)
        input.read(arr)
        var inputString = String.fromUtf8(arr)
        @Assert(inputString, "")
        var contentType = formBody.contentType().getOrThrow().toString()
        @Assert(contentType, "application/x-www-form-urlencoded")
    }

    // 创建 RealRequestBody
    @TestCase
    func okhttp_MediaType_RealRequestBody_test_029(): Unit {
        var body_01 = RealRequestBody.create(MediaType.get("application/HTML"),"hello".toUtf8Array())
        var request_01: httpclient4cj.Request = httpclient4cj.Request.builder().method("POST",body:body_01).build()
        var body_Type_01 = request_01.getBody().getOrThrow().contentType()
        match (body_Type_01) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "application")
                @Assert(get_sub, "html")
                @Assert(get_charset, "")
            case None => 
                println("None")
        }
    }

    // 读取文件内容 创建 RealRequestBody
    @TestCase
    func okhttp_MediaType_RealRequestBody_test_030(): Unit {
        var body_02 = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))
        var byteArray = Array<Byte>(body_02.getContentLength(), item: 0)
        body_02.get().read(byteArray)
        var request_02: httpclient4cj.Request = httpclient4cj.Request.builder().method("POST",body:body_02).build()
        var body_Type_02 = request_02.getBody().getOrThrow().contentType()
        match (body_Type_02) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "application")
                @Assert(get_sub, "json")
                @Assert(get_charset, "")
            case None => 
                println("None")
        }
        var body_string_02 = String.fromUtf8(byteArray)
        println(body_string_02)
        //@Assert(body_string_02, "")
    }
}
