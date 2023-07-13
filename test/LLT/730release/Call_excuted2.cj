// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import sync.sleep

main() {
    let client: HttpClient= HttpClient.builder().build()
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
    sleep(Duration.second)
    return 1
}