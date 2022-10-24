// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*
from encoding import url.*
from net import tls.*
from net import http.*

main (){
    let client = OkHttpClient.builder().addInterceptor(MyInterceptor())
    .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(),Protocol.get("HTTP/1.1").toString()])).build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://36.152.44.95/index.html")
    .header(Header())
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        let conn = chain.getConnection()
        return   chain.proceed(chain.getRequest())
    }
}