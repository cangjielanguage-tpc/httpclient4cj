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
    let request2: Request = Request.builder()
        .url("http://www.baidu.com")
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
