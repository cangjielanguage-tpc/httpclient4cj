// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj

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
from std import fs.*
from compress import zlib.*

@Test
public class okhttp_OkGzipSource_002 {

    @TestCase 
    func okhttp_OkGzipSource_002 (): Unit {
        let formBody = FormBody.builder()
            .add("username", "admin")
            .add("password", "123456")
            .add("host","%6D")
            .build()
        let cache: CacheControl = CacheControl.builder()
                                    .maxAge(1000)
                                    .build()
        let client: OkHttpClient= OkHttpClient.builder().build()
        let request: okhttp.Request = okhttp.Request.builder()
                                        .url("https://pagead2.googlesyndication.com/getconfig/sodar?sv=200&tid=gda&tv=r20221026&st=env")
                                        .method("POST", body: formBody)
                                        .cacheControl(cache)
                                        .build()
        var call = client.newCall(request)
        var response: okhttp.Response = call.execute()
        var response_protocol = response.getProtocol().toString()
        var response_code : Int64 = response.getCode()
        response.getMessage()
        var response_isSuccess:Bool= response.isSuccess()
        var response_heads = response.getHeaders()
        var response_body = response.getBody().getOrThrow().getString()
        var cacheControl = response.getCacheControl().toString()

        println("-------------------------------OKHttp-Response_Header----------------------------")
        for ((nm,vl) in response_heads) {
            println(nm)
            println(vl)
        }
        println("-------------------------------OKHttp-Response_Header----------------------------")
        println("protocol = ${response_protocol}")
        println("code = ${response_code}")
        println("isSuccess = ${response_isSuccess}")
        println("cacheControl = ${cacheControl}")

        @Assert(response_protocol,"http/1.1")
        @Assert(response.getHeader("Date").getOrThrow().contains("GMT"),true)
        @Assert(response.getHeader("Content-Type").getOrThrow(),"text/html; charset=ISO-8859-1")
        @Assert(response_body.isEmpty(), true)
        @Assert(response.getBody().getOrThrow().getContentLength(),Int64(0))
    }
}