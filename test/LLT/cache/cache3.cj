// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*

//获取缓存迭代器获取url字符串
main() {
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: HttpClient= HttpClient.builder().cache(cache).build()
    let request = httpclient4cj.Request.builder()
            .url("http://okhttp:${portTrans(50067)}/anything")
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
        if (i == "http://okhttp:${portTrans(50067)}/anything") {
            return 0
        }
    }

    return 1
}

