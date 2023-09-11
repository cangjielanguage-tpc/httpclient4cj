// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .addNetworkInterceptor(MyInterceptor())
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url("http://127.0.0.1:50060").build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}
// 自定义拦截器打印route地址
class MyInterceptor <: Interceptor {
    public func intercept(chain: Chain): httpclient4cj.Response {
        let conn = chain.getConnection().getOrThrow()
        println("route = ${conn.getRoute().getInetSocketAddress()}")
        return chain.proceed(chain.getRequest())
    }
}