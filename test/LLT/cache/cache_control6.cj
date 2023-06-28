// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

//Last-Modified: Tue, 27 May 2014 02:35:47 GMT
//ETag: "5383fa03-6df"
//协商缓存(1)  请求头部中的If-None-Match 和 If-Modified-Since 作用相同， If-None-Match优先级比 If-Modified-Since 高且更精确
//If-None-Match 对比ETag，(If-Modified-Since秒级，ETAG更小)
//（请求头部中的If-None-Match ），如果和ETAg不同，则返回最新资源，HTTP 200 OK，否则 说明资源无新修改，响应 HTTP 304 (，拦截器自动添加走缓存)
main() {
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder()
        .connectTimeout(Duration.minute*1)
        .readTimeout(Duration.minute*1)
        .writeTimeout(Duration.minute*1)
        .cache(cache)
        .build()

    /*request1*/
    let request = okhttp.Request.builder()
            .url("http://okhttp:50067/etag/5383fa03-6df")
            // .header("If-None-Match","5383fa03-6df")
            .build()
    //第一次走网络不走缓存,返回后创建缓存，code为200
    let res = client.newCall(request).execute()
    let s = res.getBody().getOrThrow().getString()
    // println("request1 ${res.getCode()} ${s}")
    let exec1 = match(res.getNetworkResponse()) {
        case Some(v) =>
            if(v.getCode()==200) {true} else {false}
        case None => false
    }
    let exec2 = match(res.getCacheResponse()) {
        case Some(v) => false
        case None => true
    }

    /*request2*/
    let request2 = okhttp.Request.builder()
        .url("http://okhttp:50067/etag/5383fa03-6df")
        .header("If-None-Match","5383fa03-6df")
        .build()
    //第二次走网络，用户手动添加不走缓存
    let res2 = client.newCall(request2).execute()
    let s2 = res2.getBody().getOrThrow().getString()
    println(s2)
    let exec3 = match(res2.getNetworkResponse()) {
        case Some(v) => if(v.getCode() == 304) {true} else {false}
        case None => false
    }
    let exec4 = match (res2.getCacheResponse()) {
        case Some(v) => false
        case None => true
    }

    if (exec1 && exec2 && exec3 && exec4) {
        return 0
    }
    println(",${exec1},${exec2},${exec3},${exec4}")
    return 1
}

