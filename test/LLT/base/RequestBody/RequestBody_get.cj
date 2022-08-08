// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
from net import http.*
from encoding import url.*
from std import collection.*

main (){
     let client: OkHttpClient= OkHttpClient.builder().protocols(
         ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])).build()
    let request = okhttp.Request.builder().
        url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        chain.connectTimeoutMillis()
        chain.readTimeoutMillis()
        chain.writeTimeoutMillis()
        chain.withConnectTimeout(1,TimeUnit())
        chain.withReadTimeout(1,TimeUnit())
        let request: http.Request = chain.getRequest().toHttpRequest()
        var ssv = ByteArrayStream()
        request.copyTo(ssv)
        var str = String(toArray(ssv.readToEnd()))
        let body = chain.getRequest().getBody().getOrThrow()
        println("${body.contentType()},${body.contentLength()},${String(toArray(ssv.readToEnd()))}")
        println(str)
        return okhttp.Response.builder().build()
    }
}