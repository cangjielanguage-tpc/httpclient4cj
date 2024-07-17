// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.http.*
import std.collection.*
import encoding.url.*
import net.tls.*
import std.socket.*
import std.time.*
import std.io.*
import std.sync.sleep

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
