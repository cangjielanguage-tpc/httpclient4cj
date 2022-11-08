// DEPENDENCE: ./body.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import fs.*


from http2 import proto.*
from http2 import common.*
from std import log.*

//使用http2,不response关闭,可以连接多路复用,对于相同请求,不需要创建新的连接,期望连接池连接数为1

main (){
    spawn {
        server()
    }
    sleep(1000*1000*1000)
    let body = RealRequestBody.create("text/json",File("./body.text",OpenOption.Open(true,false)))
    let mu = MultipartBody.builder().
    addFormDataPart("name", "lyk").
    addFormDataPart("age", "18").
    addFormDataPart("file1", "body.text", body).build()
    let client = OkHttpClient.builder()
    .protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])).build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:8899/foo")
    .method("POST", body: mu)
    .header(Header())
    .header("User-Agent", "OkHttp-Example")
    .build()

    for (i in 0..10) {
         let response: okhttp.Response = client.newCall(request).execute()
    }
    if(client.getConnectionPool().getOrThrow().connectionCount()==1){
        return 0
    }else{
        return 1
    }


}


func server () {
    let hd = http.Route()
    let str: String = "helloworld"
    hd.handle("/foo", { w, r =>
        println("=======================${String.fromUtf8(r.readToEnd())}")
        w.write(str.toUtf8Array())
    })
    let server = MultiServer(hd, Http2Cfg(http2: true, serverPort: 8899))
    server.listenAndServe()
}