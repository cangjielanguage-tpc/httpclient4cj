// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*


main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request2: Request = Request.builder().url("http://44.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .body(RequestBody("text","test"))
    .build()
    let async = client.newCall(request2)
    try {
        async.execute()
    } catch (e: Exception) {
        return 0
    }
    sleep(1000*1000*1000)
    return 1
}