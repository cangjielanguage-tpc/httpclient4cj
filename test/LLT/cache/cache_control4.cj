// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

//Last-Modified: Tue, 27 May 2014 02:35:47 GMT
//ETag: "5383fa03-6df"
//协商缓存(1)  请求头部中的 If-Modified-Since，服务器收到请求后发现有 If-Modified-Since 则与被请求资源的最后修改时间进行对比
//（Last-Modified），如果不同，则返回最新资源，HTTP 200 OK，否则 说明资源无新修改，响应 HTTP 304 (用户手动添加不走缓存，拦截器自动添加走缓存)
main() {
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder().cache(cache).build()
    let request = okhttp.Request.builder()
            .url("https://publicobject.com/helloworld.txt")
            .header("If-Modified-Since","Tue, 27 May 2022 02:35:47 GMT")
            .build()

    let res = client.newCall(request).execute()
    let s = res.getBody().getOrThrow().getString()
    //第一次走网络不走缓存,返回后创建缓存，因If-Modified-Since不同， code为200
    let exec1 = match(res.getNetworkResponse()) {
        case Some(v) =>
            if(v.getCode()==200) {true} else {false}
        case None => false
    }

    let exec2 = match(res.getCacheResponse()) {
        case Some(v) => false
        case None => true
    }
    let request2 = okhttp.Request.builder()
        .url("https://publicobject.com/helloworld.txt")
        .header("If-Modified-Since","Tue, 27 May 2014 02:35:47 GMT")
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

    return 1
}

