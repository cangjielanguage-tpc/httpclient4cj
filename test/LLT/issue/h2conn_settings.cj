// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
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

public var port: UInt16 = 50066
public let TEST_STR: String = "http2 server write"

main() {
    let formBody = FormBody.builder()
        .add("username", "admin")
        .add("password", "123456")
        .add("host", "%6D")
        .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://okhttp:${portTrans(port)}/cangjie_test-1.0-SNAPSHOT/put")
        .header("User-Agent", "OkHttp-Example")
        .put(formBody)
        .header("content-type", formBody.contentType().getOrThrow().toString())
        .build()
    let soc = TcpSocket("okhttp", portTrans(port))
    soc.connect()
    let sc = SocketClient.SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))

    h2conn.start()
    var s02 = Settings()
    s02.setting(4, 400)
    s02.setting(1, 200)
    h2conn.setSettings(s02)
    var h2stream = h2conn.newStream(request)
    var ba = ByteArrayStream()
    var arr01 = Array<Byte>(100, item: 8)
    ba.write(arr01)
    h2conn.writeData(h2stream.getId(), true, ba, 100)
    h2conn.flush()

    sleep(Duration.second)
    return 0
}
