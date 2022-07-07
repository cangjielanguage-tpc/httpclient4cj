// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

main (){
    var cache = CacheControl.builder()
                            .noCache()
                            .noStore()
                            .maxAge(Duration.second(10))
                            .maxStale(Duration.second(10))
                            .minFresh(Duration.second(10))
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