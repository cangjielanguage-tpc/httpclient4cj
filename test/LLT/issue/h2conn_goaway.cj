// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import log.*
from std import sync.sleep

public var port:UInt16=50066
public let TEST_STR: String = "http2 server write"

main () {
    let formBody = FormBody.builder()
                        .add("username", "admin")
                        .add("password", "123456")
                        .add("host","%6D")
                        .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/cangjie_test-1.0-SNAPSHOT/put")
                         .header("User-Agent", "OkHttp-Example").put(formBody)
                        .header("content-type",formBody.contentType().getOrThrow().toString())
                        .header("trailer", "123")
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
    trailers.set("kkk", "ttt")
    h2stream.enqueueTrailers(trailers)
    formBody.writeTo(sink)
    sink.close()
    h2stream.getSource().read(ByteArrayStream(),10)
    sleep(Duration.second)
    return 0
    }