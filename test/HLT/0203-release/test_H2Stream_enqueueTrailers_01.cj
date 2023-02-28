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

main():Int64{
    var port:UInt16=36389
    let formBody = FormBody.builder()
                        .add("username", "admin")
                        .add("password", "123456")
                        .add("host","%6D")
                        .build()

    let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:${port}/foo")
                                                        .header("User-Agent", "OkHttp-Example").put(formBody)
                                                        .header("content-type",formBody.contentType().getOrThrow().toString())
                                                        .build()

    let soc = Socket(TCP,"127.0.0.1", port)
    soc.connect()
    let sc = SocketClient.SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))

    h2conn.start()
    let h2stream = h2conn.newStream(request)
    let sink = h2stream.getSink()
    let trailers = Header()
    trailers.set("123", "ttt")
    h2stream.enqueueTrailers(trailers)
    formBody.writeTo(sink)
    sink.close()//此用例只是触发用例，需要抓包确认用例结果
    sleep(10*1000*1000*1000)
    0
}