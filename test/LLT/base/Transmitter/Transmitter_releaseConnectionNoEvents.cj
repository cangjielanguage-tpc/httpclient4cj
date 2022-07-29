// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*


main (){
    let client = OkHttpClient.builder().addNetworkInterceptor(MyInterceptor())
    .build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        println("tr=======")
        let tr = chain.getTransmitter()
        println("tr=======")
        tr.releaseConnectionNoEvents()
        tr.acquireConnectionNoEvents(chain.getConnection().getOrThrow())
        return okhttp.Response.builder().build()
    }
}