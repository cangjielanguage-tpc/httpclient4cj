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

//创建h2conn 和 stream，发送data 帧 关闭 stream

main (){
     let formBody = FormBody.builder()
    .add("username", "admin")
    .add("password", "123456")
    .add("host","%6D")
    .build()
     let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/put")
    .header("User-Agent", "OkHttp-Example").put(formBody)
    .header("content-type",formBody.contentType())
    .build()
    let soc = Socket(TCP,"127.0.0.1", 50066)
    soc.connect()
    let sc = SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    h2conn.start()
    let s = Settings()
    s.setting(Settings.INITIAL_WINDOW_SIZE, 65535)
    h2conn.setSettings(s)
    let stream = h2conn.newStream(request)
    stream.close(ErrorCode.INTERNAL_ERROR, "")
    sleep(1000*1000*1000)
    return 0
}
