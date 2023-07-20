// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep

var port: UInt16 = 0
main() {
    serve()
    //http://127.0.0.1:${port}/1234
    //http://www.zhihu.com
    //http://www.baidu.com/index.html
    //https://www.zhihu.com/signin?next=%2F
    //"https://restapi.amap.com/v3/weather/weatherInfo?city=深圳&key=13eb58f5884f9749287abbead9c65"
    //http://www.weather.com.cn/data/sk/101010100.html
    //http://wjhsh.net/Jimc-p-10250861.html
    let url: URL = URL.parse("http://www.weather.com.cn/data/sk/101010100.html")
    let client: HttpClient = HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)
    try {
        let response: httpclient4cj.Response = call.execute()
        println(response.toString())
        println(response.getBody().getOrThrow().getContentLength())
        //println(response.getBody().getOrThrow().getString())
        println("count1 =======================")
        println(client.getConnectionPool().getOrThrow().connectionCount())
        println(client.getConnectionPool().getOrThrow().idleConnectionCount())
        client.newCall(request).execute()
        println("count =======================")
        println(client.getConnectionPool().getOrThrow().connectionCount())
        println(client.getConnectionPool().getOrThrow().idleConnectionCount())
    } catch (e: Exception) {
        e.printStackTrace()
        return 1
    }
    return 0
}

func serve() {
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder.new().listener(serverSocket).build()
    server.distributor.register("/1234",
        {
        httpContext =>
        let resp = "Hello from /red".toUtf8Array()
        //httpContext.responseBuilder.status(301)
        //httpContext.responseBuilder.header("Location","http://127.0.0.1:${port}/1234")
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn {server.serve()}
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}
