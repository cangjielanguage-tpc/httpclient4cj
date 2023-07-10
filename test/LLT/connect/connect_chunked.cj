// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import sync.sleep

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request2: Request = Request.builder().url("http://www.baidu.com")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let async = client.newCall(request2)
    try {
        let resp = async.execute()
        resp.getBody()?.getString()
    } catch (e: Exception) {
        return 1
    }
    sleep(Duration.second)
    return 0
}