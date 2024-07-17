// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
import net.http.*
import net.tls.*
import std.socket.*
import httpclient4cj
import httpclient4cj.*
import std.io.*

main() {
    let socket = TcpSocket("www.baidu.com", portTrans(80))
    let socketC = SocketC(socket)
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://36.152.44.95/index.html")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let requestStream = ByteArrayStream()
    let req4cj = toHttpRequest(request)
    req4cj.copyTo(requestStream)
    socketC.connect()
    socketC.write(requestStream.readToEnd())
    var readBuf: Array<Byte> = Array<Byte>(1024, item: 0)
    socketC.read(readBuf)
    socketC.close()
}
