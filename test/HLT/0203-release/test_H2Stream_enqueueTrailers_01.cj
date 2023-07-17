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
from std import sync.sleep

main():Int64{
    var port:UInt16=36389
    let formBody = FormBody.builder()
                        .add("username", "admin")
                        .add("password", "123456")
                        .add("host","%6D")
                        .build()

    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/foo")
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
    sleep(10*Duration.second)
    0
}