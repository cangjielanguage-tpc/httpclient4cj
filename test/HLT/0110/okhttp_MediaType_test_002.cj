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

@Test
public class okhttp_MediaType_test_002{

    // get 创建 MediaType 无格式字母数字组合
    @TestCase
    func okhttp_MediaType_test_011(): Unit {
        try {
            var mediaType = MediaType.get("q890qh7fbkxdv")
        } catch (ex: Exception) {
            println(ex)
        }
    }

    // parse 创建 MediaType 无格式字母数字组合
    @TestCase
    func okhttp_MediaType_test_012(): Unit {
        var mediaType = MediaType.parse("q890qh7fbkxdv")
        match (mediaType) {
            case Some(contentType) =>
                var mediaType = MediaType.get("q890qh7fbkxdv")
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "text")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "utf-8")
            case None => 
                println("None")
        }
    }

    // get 创建 MediaType 特殊符号
    @TestCase
    func okhttp_MediaType_test_013(): Unit { 
        try {
            var mediaType = MediaType.get("#$%^@#&*$/{#}<>:?>[#], ch=}; charset=utf-8")
            var get_type = mediaType.getType()
            var get_sub = mediaType.getSubtype()
            var get_charset = mediaType.getCharset()
            
            @Assert(get_type, "#$%^@#&*$")
            @Assert(get_sub, "{#}<>:?>[#], ch=}")
            @Assert(get_charset, "utf-8")
        } catch (ex: Exception) {
            @Expect(ex is IllegalArgumentException) 
        }
        
    }

    // parse 创建 MediaType 特殊符号
    @TestCase
    func okhttp_MediaType_test_014(): Unit {
        var mediaType = MediaType.parse("#$%^@#&*$/{}<>:?>[], ch=}; charset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                var get_type = contentType.getType()
                var get_sub = contentType.getSubtype()
                var get_charset = contentType.getCharset()
                @Assert(get_type, "text")
                @Assert(get_sub, "xxxxx")
                @Assert(get_charset, "utf-8")
            case None => 
                println("None")
        }
    }

    // get 创建 MediaType 中间有其他参数
    @TestCase
    func okhttp_MediaType_test_015(): Unit {
        try {
            var mediaType = MediaType.get("text/aaaaa; xxxxxx/xxxx; xxxx=xxxxxx; charset=utf-8")
        } catch (ex: Exception) {
            println(ex)
        }   
    }

    // parse 创建 MediaType 中间有其他参数
    @TestCase
    func okhttp_MediaType_test_016(): Unit {
        var mediaType = MediaType.parse("text/aaaaa; xxxxxx/xxxx; xxxx=xxxxxx; charset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                println(contentType)
            case None => 
                println("None")
        }        
    }

    // get 创建 MediaType 中文
    @TestCase
    func okhttp_MediaType_test_017(): Unit {
        try {
            var mediaType = MediaType.get("文本类型/某某格式; charset=utf-8")
        } catch (ex: Exception) {
            println(ex)
        }      
    }

    // parse 创建 MediaType 中文
    @TestCase
    func okhttp_MediaType_test_018(): Unit {
        var mediaType = MediaType.parse("文本类型/某某格式; charset=utf-8")
        match (mediaType) {
            case Some(contentType) =>
                println(contentType)
            case None => 
                println("None")
        }        
    }

    // get 创建 MediaType 中文
    @TestCase
    func okhttp_MediaType_test_019(): Unit {
        try {
            var mediaType = MediaType.get("文本类型/某某格式; 数据集=中文")
        } catch (ex: Exception) {
            println(ex)
        }          
    }

    // parse 创建 MediaType 中文
    @TestCase
    func okhttp_MediaType_test_020(): Unit {
        var mediaType = MediaType.parse("文本类型/某某格式; 数据集=中文")
        match (mediaType) {
            case Some(contentType) =>
                println(contentType)
            case None => 
                println("None")
        }               
    }

    // get 创建 MediaType 无格式中文
    @TestCase
    func okhttp_MediaType_test_021(): Unit {
        try {
            var mediaType = MediaType.get("文本类型某某格式数据集中文")
        } catch (ex: Exception) {
            println(ex)
        }  
    }

    // parse 创建 MediaType 无格式中文
    @TestCase
    func okhttp_MediaType_test_022(): Unit {
        var mediaType = MediaType.parse("文本类型某某格式数据集中文")
        match (mediaType) {
            case Some(contentType) =>
                println(contentType)
            case None => 
                println("None")
        }  
    }
}
