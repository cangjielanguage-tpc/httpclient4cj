package okhttp

from net import http.*
from std import io.*
from std import socket.*

var port: UInt16 = 12340

main() {
    //main2()
    var requestStream: StringStream = StringStream("")
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getSource().toString())
    ()
}


func main2(): Unit {
spawn {
serve()
}
sleep(1000*1000*1000)
let ss = StringStream("foo=bar&foo=bar2&bar=baz")
var sso: Option<ReadCloseStream> = Some(ss)
var ssv = StringStream("")
var req = http.Request(RequestMethod.GET, "http://36.152.44.95/index.html", stream: sso)
//req.header.add("Accept-Encoding","gzip")
req.header.add("Connection-Encoding","Keep-Alive")
var b =  Transport.getDefault().roundTrip(req)
execute(b, req)
//execute(b, req)
()
}

func execute(b: PersistConn, req: http.Request): Unit {
let a = b.roundTripTrans(req)
var w = StringStream("")
a.write(w)

var str = String(w.getChars())
println(str)
}


func serve(){
let hd = http.Route()
hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
let resp = "Hello from /red".toUtf8Array()
rws.write(resp)
return
})
let server = Server(hd)
let socket = SocketServer(SocketNet.TCP, "0.0.0.0", port)
port = socket.port
server.serve(socket) }