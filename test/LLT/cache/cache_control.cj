// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main() {
    let forceNet = CacheControl.FORCE_NETWORK //强制网络的缓存控制
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder().cache(cache).build()
    let request1 = okhttp.Request.builder()
            .cacheControl(forceNet)
            .url("http://okhttp:50067/get")
            .method("GET")
            .build()
    let request2 = okhttp.Request.builder()
            .cacheControl(forceNet)
            .url("http://okhttp:50067/get")
            .method("GET")
            .build()

    let res = client.newCall(request1).execute()
    let s = res.getBody().getOrThrow().getString()
    println("${res} ${s.size}")

    let b = client.newCall(request2).execute()
    println(b)
    return 0
}

