// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*


main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let sync = client.newCall(request)
    sync.execute()
    try {
        sync.execute()
    } catch (e: Exception) {
        return 0
    }
    sleep(1000*1000*1000)
    return 1
}