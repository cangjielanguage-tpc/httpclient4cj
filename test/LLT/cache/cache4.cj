// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*

//删除缓存文件
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

    let size1 = cache.getSize()
    //去除缓存内存以及缓存文件
    cache.evictAll()
    //此时size应为0
    let size2 = cache.getSize()
    if (size1 > 0 && size2 ==0) {
        return 0
    }
    return 1
}

