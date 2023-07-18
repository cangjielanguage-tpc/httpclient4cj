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
public class okhttp_DNS_001{

    @TestCase
    func okhttp_DNS_001(): Unit {
    let cache: CacheControl = CacheControl.builder()
                                .maxAge(1000)
                                .build()
    let client: HttpClient= HttpClient.builder().build()
    // let body: httpclient4cj.RequestBody = httpclient4cj.RequestBody("Media-Type", "text/html")
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://www.baidu.com/index.html")
                                    .method("GET")//加body
                                    .cacheControl(cache)
                                    .build()
    var call = client.newCall(request)
    var response: httpclient4cj.Response = call.execute()
    var response_protocol = response.getProtocol().toString()
    var response_code : Int64 = response.getCode()
    var response_Message = response.getMessage()
    var response_isSuccess:Bool= response.isSuccess()
    var response_heads: http.Header = response.getHeaders()
    // var response_body:Array<Byte> = response.getBody().getOrThrow().getSource().readToEnd()
    // var response_body_str = String.fromUtf8(response_body)
    var cacheControl = response.getCacheControl().toString()
    //var request2 = response.getRequest()

    // println("response_body")
    // println(response_body_str)

    println("-------------------------------OKHttp-Response_Header----------------------------")
    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    println("-------------------------------OKHttp-Response_Header----------------------------")
    println("protocol = ${response_protocol}")
    println("code = ${response_code}")
    println("isSuccess = ${response_isSuccess}")
    println("cacheControl = ${cacheControl}")//????
    
    @Assert(response_protocol,"http/1.1")
    @Assert(response_code,Int64(200))
    @Assert(response_Message,"OK")
    @Assert(response_isSuccess,true)
    //@Assert(response.getHeader("Content-Length").getOrThrow(),"15")???
    @Assert(response.getHeader("Date").getOrThrow().contains("GMT"),true)
    @Assert(response.getHeader("Connection").getOrThrow(),"keep-alive")
    // @Assert(response.getHeader("Content-Type").getOrThrow(),"text/html; charset=utf-8")
    // @Assert(response_body_str.isEmpty(), false)
    //@Assert(cacheControl, )

    }
}