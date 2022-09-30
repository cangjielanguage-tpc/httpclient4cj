// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/http2

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
public class okhtttp_DNS_002{

    @TestCase
    func okhtttp_DNS_002(): Unit {
    let cache: CacheControl = CacheControl.builder()
                                .maxAge(Duration.second(1000))
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://www.google.cn/index.html")
                                    .method("GET")
                                    .cacheControl(cache)
                                    //.body(body)
                                    .build()
    var call = client.newCall(request)
    var response: okhttp.Response = call.execute()
    var response_protocol = response.getProtocol().toString()
    var response_code : Int64 = response.getCode()
    var response_Message = response.getMessage()
    var response_isSuccess:Bool= response.isSuccess()
    var response_heads: http.Header = response.getHeaders()
    var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
    var response_body_str = String.fromUtf8(response_body)
    var cacheControl = response.getCacheControl().getOrThrow().toString()
    //var request2 = response.getRequest()

    var httpRequest = request.toHttpRequest()
    let arr =ByteArrayStream()
    httpRequest.copyTo(arr)

    println("httpRequest")
    println(String.fromUtf8(arr.bytes()))

    //println("response_body")
    //println(response_body_str)

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
    @Assert(response_code,Int64(200))
    @Assert(response_Message,"OK")
    @Assert(response_isSuccess,true)
    @Assert(response.getHeader("Date").getOrThrow().contains("GMT"),true)
    @Assert(response_body_str.isEmpty(), false)
    @Assert(cacheControl, "no-cache, must-revalidate")

    }
}