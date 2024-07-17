// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import net.http.*
import std.socket.*
import httpclient4cj
import httpclient4cj.*
import std.io.*
import std.time.*

main() {
    let socket = TcpSocket("www.baidu.com", portTrans(80))
    let socketC = SocketC(socket)
    socketC.connect(Duration.millisecond * 10000)
    println(socket.isClosed())
}
