// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import collection.*
from std import socket.*
from net import http.*

main (){
    let client: OkHttpClient= OkHttpClient.builder().connectTimeout(Duration.millisecond*100)
    .addNetworkInterceptor(MyInterceptor())
    .readTimeout(Duration.second).writeTimeout(Duration.second).build()
    let request= okhttp.Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        let request = chain.getRequest()
        let conn = chain.getConnection()
        conn?.getSocket()
        let call = chain.getCall()
        return chain.proceed(request)
    }
}