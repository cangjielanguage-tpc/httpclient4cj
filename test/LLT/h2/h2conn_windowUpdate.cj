// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import socket.*
from std import time.*
from std import io.*
from std import fs.*


//创建h2conn 和 stream，发送data 帧时由于流量窗口不足,必须阻塞等待 服务端发送流量窗口才能继续发送

main (){
     var arr: Array<Byte> = Array<Byte>(81000, {i => UInt8(i % 256)})
     File.writeTo("./window.text", arr, openOption: Create(false))
     let body = RealRequestBody.create(MediaType.get("application/json"),File("./window.text",OpenOption.Open(true,false)))
     let mu = MultipartBody.builder().
     addFormDataPart("name", "lyk").
     addFormDataPart("age", "18").
     addFormDataPart("file1", "body.text", body).build()
     let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/post")
    //.header("User-Agent", "OkHttp-Example")
    //未使用拦截器手动添加请求头
    .header("content-type",mu.contentType().getOrThrow().toString())
    .header("Host","127.0.0.1:50066")
    .header("content-length",mu.getContentLength().toString())
    .post(mu)
    .build()
    let soc = Socket(TCP,"127.0.0.1", 50066)
    soc.connect()
    let sc = SocketC(soc)
    let socket = OKSocket(sc, Duration.minute(1), Duration.minute(1))
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    h2conn.start()
    let stream = h2conn.newStream(request)
    let sink = RealBufferSink(stream.getSink())
    mu.writeTo(sink)
    sink.flush()
    sleep(1000*1000*1000)
    File.delete("./window.text")
    return 0
}
