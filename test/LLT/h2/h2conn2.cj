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

//创建h2conn 和 stream，发送data 帧 以及trailers的header帧

main() {
    let formBody = FormBody.builder().add("username", "admin").add("password", "123456").add("host", "%6D").build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/put")
        .header("User-Agent", "OkHttp-Example")
        .put(formBody)
        .header("content-type", formBody.contentType().getOrThrow().toString())
        .build()
    let soc = TcpSocket("okhttp", portTrans(50066))
    soc.connect()
    let sc = SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    h2conn.start()
    let stream = h2conn.newStream(request)
    let sink = stream.getSink()
    let trailers = Header()
    trailers.add("test", "ttt")
    stream.enqueueTrailers(trailers)
    formBody.writeTo(sink)
    sleep(Duration.second)
    try {
        sink.close()
    } catch (e: Exception) {
        return 1
    }
    return 0
}
