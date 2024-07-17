// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*

main() {
    let forceNet = CacheControl.FORCE_NETWORK //强制网络的缓存控制
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: HttpClient= HttpClient.builder().cache(cache).build()
    let request1 = httpclient4cj.Request.builder()
            .cacheControl(forceNet)
            .url("http://okhttp:${portTrans(50067)}/get")
            .method("GET")
            .build()
    let request2 = httpclient4cj.Request.builder()
            .cacheControl(forceNet)
            .url("http://okhttp:${portTrans(50067)}/get")
            .method("GET")
            .build()

    let res = client.newCall(request1).execute()
    let s = res.getBody().getOrThrow().getString()
    println("${res} ${s.size}")

    let b = client.newCall(request2).execute()
    println(b)
    return 0
}

