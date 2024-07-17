// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.sync.sleep

main() {
    let client: HttpClient= HttpClient.builder().build()
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