// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from std import time.*
from httpclient4cj import httpclient4cj.*


//第一次走网络不使用缓存，第二次缓存不走网络(此时应该只生成tmp文件,cache只保存在内存中)
main() {
    let cc = CacheControl.builder()
        .noCache()//不使用缓存，所有走网络
        .noStore()//不使用缓存，也不存储缓存
        .maxAge(3600)//指示客户机能够接收响应时间小于当前时间加上指定时间的响应
        .maxStale(3600)//指示客户机能够接收超出超时期间的响应消息
        .minFresh(3600)//指示客户机能够接收生存期不大于指定时间的响应
        .onlyIfCached()//只使用缓存
        .noTransform()//禁止转码
        .immutable().build()
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: HttpClient= HttpClient.builder()
        .connectTimeout(Duration.minute*1)
        .readTimeout(Duration.minute*1)
        .writeTimeout(Duration.minute*1)
        .cache(cache)
        .build()

    /*request1*/
    let request = httpclient4cj.Request.builder()
            .url("http://okhttp:${portTrans(50067)}/cache/1000")
            .method("GET")
            .build()
    let res = client.newCall(request).execute()
    let s = res.getBody().getOrThrow().getString()
    println(s)
    //第一次走网络不走缓存
    let exec1 = match(res.getNetworkResponse()) {
        case Some(v) => true
        case None => false
    }
    let exec2 = match(res.getCacheResponse()) {
        case Some(v) => false
        case None => true
    }

    /*request2*/
    //第二次走缓存不走网络
    let res2 = client.newCall(request).execute()
    let s2 = res2.getBody().getOrThrow().getString()
    println(s2)
    let exec3 = match(res2.getNetworkResponse()) {
        case Some(v) => false
        case None => true
    }

    let exec4 = match(res2.getCacheResponse()) {
        case Some(v) => true
        case None => false
    }

    /*res*/
    if (exec1 && exec2 && exec3 && exec4) {
        return 0
    }
    println("${exec1} ${exec2} ${exec3} ${exec4}")
    return 1
}

