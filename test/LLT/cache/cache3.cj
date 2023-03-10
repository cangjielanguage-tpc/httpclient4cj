// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

//获取缓存迭代器获取url字符串
main() {
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder().cache(cache).build()
    let request = okhttp.Request.builder()
            .url("https://httpbin.org/anything")
            .build()

    let res = client.newCall(request).execute()
    let s = res.getBody().getOrThrow().getString()
    //第一次走网络不走缓存,返回后创建缓存
    let exec1 = match(res.getNetworkResponse()) {
        case Some(v) =>true
        case None => false
    }

    let exec2 = match(res.getCacheResponse()) {
        case Some(v) => false
        case None => true
    }

    for (i in cache.urls()) {
        if (i == "https://httpbin.org/anything") {
            return 0
        }
    }

    return 1
}

