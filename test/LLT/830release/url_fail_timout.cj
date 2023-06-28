// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import sync.sleep

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request2: Request = Request.builder().url("http://44.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let async = client.newCall(request2)
    try {
        async.execute()
    } catch (e: Exception) {
        return 0
    }
    sleep(Duration.second)
    return 1
}