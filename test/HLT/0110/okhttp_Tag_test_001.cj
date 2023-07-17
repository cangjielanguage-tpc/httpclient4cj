// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj

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
public class okhttp_Tag_Test_001{

    // 设置 tag 后获取
    @TestCase
    func okhttp_Tag_Test_001(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().tag("tag_test").build()
        var request_tag = request.getTag("tag_test").tag
        @Assert(request_tag, "tag_test")
    }

    // 设置tag 移除tag
    @TestCase
    func okhttp_Tag_Test_002(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().tag("tag_test").build()
        var request_tag = request.getTag("tag_test").tag
        @Assert(request_tag, "tag_test")
        request.removeTag("tag_test")
        var request_tag_remove = request.getTag("tag_test").tag
        @Assert(request_tag_remove, "")
    }

    // 不设置直接获取tag 
    @TestCase
    func okhttp_Tag_Test_003(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().build()
        var request_tag_01 = request.getTag("").tag
        @Assert(request_tag_01, "")
        var request_tag_02 = request.getTag("tag_test").tag
        @Assert(request_tag_02, "")
    }

    // 移除不存在的 tag 
    @TestCase
    func okhttp_Tag_Test_004(): Unit {
        let request: httpclient4cj.Request = httpclient4cj.Request.builder().build()
        request.removeTag("tag_test")
        var request_tag_01 = request.getTag("").tag
        @Assert(request_tag_01, "")
        var request_tag_02 = request.getTag("tag_test").tag
        @Assert(request_tag_02, "")
    }

    // 设置多个 tag 后全部移除
    @TestCase
    func okhttp_Tag_Test_005(): Unit {
        var tags = ["tag_test_01", "tag_test_02", "tag_test_03", "tag_test_04", "tag_test_05",
                    "tag_test_06", "tag_test_07", "tag_test_08", "tag_test_09", "tag_test_10"]
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[0])
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .tag(tags[4])
                                        .tag(tags[5])
                                        .tag(tags[6])
                                        .tag(tags[7])
                                        .tag(tags[8])
                                        .tag(tags[9])
                                        .build()
        for (tag in tags) {
            var request_tag = request.getTag(tag).tag
            @Assert(request_tag, tag)
            request.removeTag(tag)
            request_tag = request.getTag(tag).tag
            @Assert(request_tag, "")
        }
    }

    // 设置多个 tag 后移除未设置的 tag
    @TestCase
    func okhttp_Tag_Test_006(): Unit {
        var tags = ["tag_test_01", "tag_test_02", "tag_test_03", "tag_test_04", "tag_test_05",
                    "tag_test_06", "tag_test_07", "tag_test_08", "tag_test_09", "tag_test_10"]
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tags[0])
                                        .tag(tags[1])
                                        .tag(tags[2])
                                        .tag(tags[3])
                                        .tag(tags[4])
                                        .tag(tags[5])
                                        .tag(tags[6])
                                        .tag(tags[7])
                                        .tag(tags[8])
                                        .tag(tags[9])
                                        .build()
        request.removeTag("tag")
        var request_tag = request.getTag("tag").tag
        @Assert(request_tag, "")

        for (tag in tags) {
            var request_tag_tmp = request.getTag(tag).tag
            @Assert(request_tag_tmp, tag)
            request.removeTag(tag)
            request_tag_tmp = request.getTag(tag).tag
            @Assert(request_tag_tmp, "")
        }
    }

    // tag 值为特殊符号
    @TestCase
    func okhttp_Tag_Test_007(): Unit {
        var tagString:String = "!@#$%^%&*(*()+[]\\',[].''  /*-+ #### <>?:"
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tagString)
                                        .build()
        var request_tag = request.getTag(tagString).tag
        @Assert(request_tag, tagString)
        request.removeTag(tagString)
        var request_tag_remove = request.getTag(tagString).tag
        @Assert(request_tag_remove, "")
    }

    // tag 值为中文
    @TestCase
    func okhttp_Tag_Test_008(): Unit {
        var tagString:String = "中文tag——中文tag——中文tag——中文tag——中文tag——中文tag"
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tagString)
                                        .build()
        var request_tag = request.getTag(tagString).tag
        @Assert(request_tag, tagString)
        request.removeTag(tagString)
        var request_tag_remove = request.getTag(tagString).tag
        @Assert(request_tag_remove, "")
    }

    // tag 值长度超长
    @TestCase
    func okhttp_Tag_Test_009(): Unit {
        var tagString:String = StringBuilder('t', 2048).toString()
        let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                        .tag(tagString)
                                        .build()
        var request_tag = request.getTag(tagString).tag
        @Assert(request_tag, tagString)
        request.removeTag(tagString)
        var request_tag_remove = request.getTag(tagString).tag
        @Assert(request_tag_remove, "")
    }

}

