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

//创建h2conn 并发送 goaway 关闭连接,此时再创建stream将抛出异常

main() {
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(
        "http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello").header("User-Agent", "OkHttp-Example").
        build()
    let soc = TcpSocket("okhttp", portTrans(50066))
    soc.connect()
    let sc = SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    h2conn.start()
    h2conn.close()
    sleep(Duration.second)
    try {
        let stream = h2conn.newStream(request)
    } catch (e: Exception) {
        return 0
    }
    return 1
}
