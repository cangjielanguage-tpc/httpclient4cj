package okhttp

from net import http.*
from std import io.*
from std import socket.*

var port: UInt16 = 12340

main() {
spawn {
serve()
}
sleep(1000*1000*1000)
let ss = StringStream("foo=bar&foo=bar2&bar=baz")
var sso: Option<ReadCloseStream> = Some(ss)
var ssv = StringStream("")
var req = http.Request(RequestMethod.GET, "http://127.0.0.1:${port}/1234", stream: sso)
var b =  Transport.getDefault().roundTrip(req)
execute(b, req)
execute(b, req)
()
}

func execute(b: PersistConn, req: http.Request): Unit {
let a = b.roundTripTrans(req)
var w = StringStream("")
a.write(w)

var str = String(w.getChars())
println(str)
println(a.request.host)

}


func serve(){
let hd = Route()
hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
let resp = "Hello from /red".toUtf8Array()
println("12340")
rws.write(resp)
return
})
let server = Server(hd)
let socket = SocketServer(SocketNet.TCP, "0.0.0.0", port)
port = socket.port
server.serve(socket) }
