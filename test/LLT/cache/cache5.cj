// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import fs.*
//获取缓存迭代器获取url字符串
main() {
    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: OkHttpClient= OkHttpClient.builder().cache(cache).build()
    let request = okhttp.Request.builder()
            .url("https://publicobject.com/helloworld.txt")
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
    //删除缓存文件以及journal
    cache.delete()
    //但不删除内存中的缓存，此时size2应为size1
    let size2 = cache.getSize()

    if (size1 > 0 && size2 == size1) {
        //删除缓存目录下所有文件
        if (Directory("./cacheccccccc").entryList().size == 0) {
            return 0
        }
    }
    return 1
}

