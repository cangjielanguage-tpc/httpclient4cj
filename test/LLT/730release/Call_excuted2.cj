// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.sync.sleep

main() {
    let client: HttpClient = HttpClient.builder().build()
    let request: Request = Request.builder()
        .url("http://36.152.44.95/index.html")
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
