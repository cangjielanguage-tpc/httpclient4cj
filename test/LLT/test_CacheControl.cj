// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

main (){
    var cache = CacheControl.builder()
                            .noCache()
                            .noStore()
                            .maxAge(10)
                            .maxStale(10)
                            .minFresh(10)
                            .onlyIfCached()
                            .noTransform()
                            .immutable()
                            .build()
    println("noCache: ${cache.noCache()}")
    println("noCache: ${cache.noStore()}")
    println("noCache: ${cache.maxAgeSeconds()}")
    println("noCache: ${cache.sMaxAgeSeconds()}")
    println("noCache: ${cache.isPrivate()}")
    println("noCache: ${cache.isPublic()}")
    println("noCache: ${cache.mustRevalidate()}")
    println("noCache: ${cache.maxStaleSeconds()}")
    println("noCache: ${cache.minFreshSeconds()}")
    println("noCache: ${cache.onlyIfCached()}")
    println("noCache: ${cache.noTransform()}")
    println("noCache: ${cache.immutable()}")
    return 0
}