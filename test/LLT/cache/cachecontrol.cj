// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*

from net import http.*


main() {
    //实际使用时不应该都调用
    let cc = CacheControl.builder()
        .noCache()//不使用缓存，所有走网络
        .noStore()// 不存储缓存
        .maxAge(3600)//缓存最大有效时间
        .maxStale(3600)//指示客户机能够接收超出超时期间的响应消息
        .minFresh(3600)//指示客户机能够接收生存期不大于指定时间的响应
        .onlyIfCached()//只使用缓存
        .noTransform()//禁止转换
        .immutable()//资源不变
        .build()

    let header: Header = Header()

    header.set("cache-control",
        "no-cache, no-store, max-age=3600, max-stale=3600, min-fresh=3600, only-if-cached, no-transform, immutable")
    let cc2 = CacheControl.parse(header)

    if ("${cc2}" == "${cc}") {
        return 0
    } else {
        return 1
    }
}

