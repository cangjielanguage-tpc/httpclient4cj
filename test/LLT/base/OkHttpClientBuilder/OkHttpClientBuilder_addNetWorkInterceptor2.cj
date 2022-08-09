// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import collection.*
from std import socket.*
from net import http.*

main (){
    let client = OkHttpClient.builder().addNetworkInterceptor(MyInterceptor())
    .protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])).build()
    let request: okhttp.Request = okhttp.Request.builder()
    .url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        let request = chain.getRequest()
        let exchange: Exchange = chain.getExchange()
        exchange.write(request)
        let respB = exchange.readResponseHeaders()
        .body(exchange.openResponseBody())
        .request(request)
        let tr = chain.getTransmitter()
        let poor = ConnectionPool()
        poor.connectionCount()
        poor.idleConnectionCount()
        poor.evictAll()
        tr.acquireConnectionNoEvents(chain.getConnection().getOrThrow())
        tr.releaseConnectionNoEvents()
         println("tr=======")

        println("tr=======")
        return respB.build()
    }
}