// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import socket.*
from std import time.*
from std import io.*
from std import sync.sleep

//创建h2conn 和 stream，在start() 调用前发送settings帧， 发送goAway帧

main() {
    let formBody = FormBody.builder().add("username", "admin").add("password", "123456").add("host", "%6D").build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://127.0.0.1:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/put")
        .header("User-Agent", "OkHttp-Example")
        .put(formBody)
        .header("content-type", formBody.contentType().getOrThrow().toString())
        .build()
    let soc = TcpSocket("127.0.0.1", portTrans(50066))
    soc.connect()
    let sc = SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    let s = Settings()
    s.setting(Settings.INITIAL_WINDOW_SIZE, Int64(portTrans(50066)))
    h2conn.start()
    h2conn.setSettings(s)
    let stream = h2conn.newStream(request)
    stream.closeLater(ErrorCode.INTERNAL_ERROR)
    sleep(Duration.second * 10)
    return 0
}
