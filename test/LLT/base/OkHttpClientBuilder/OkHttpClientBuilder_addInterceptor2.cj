// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj

// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*
import encoding.url.*
import net.tls.*
import net.http.*

main() {
    let client = HttpClient.builder()
        .addInterceptor(MyInterceptor())
        .protocols(ArrayList<String>([httpclient4cj.Protocol.get("HTTP/2.0").toString(), httpclient4cj.Protocol.get("HTTP/1.1").toString()]))
        .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://36.152.44.95/index.html")
        .header(Header())
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor <: Interceptor {
    public func intercept(chain: Chain): httpclient4cj.Response {
        let conn = chain.getConnection()
        return chain.proceed(chain.getRequest())
    }
}
