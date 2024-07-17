// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.collection.*
import std.socket.*
import net.http.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.millisecond * 100)
        .addNetworkInterceptor(MyInterceptor())
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = httpclient4cj.Request.builder()
        .url("http://36.152.44.95/index.html")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response = client.newCall(request).execute()
    return 0
}

class MyInterceptor <: Interceptor {
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request = chain.getRequest()
        let conn = chain.getConnection()
        conn?.getSocket()
        let call = chain.getCall()
        return chain.proceed(request)
    }
}
