// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*


//缓存控制强制使用缓存时，若无法读取到响应缓存，则返回504的响应
var port: UInt16 = 0
main() {
    let forceNet = CacheControl.FORCE_CACHE //强制使用缓存的缓存控制
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder().cache(cache).build()
    let request = okhttp.Request.builder()
            .cacheControl(forceNet)
            .url("https://httpbin.org/cache")
            .build()
    let res = client.newCall(request).execute()
    println(res.getCode())
    if (res.getCode() == 504) {
        0
    } else {
        1
    }
}

