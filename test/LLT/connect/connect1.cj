// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient= HttpClient.builder().build()
    let request: Request = Request.builder()
        .url("http://36.152.44.95/index.html")
        .header("User-Agent", "OkHttp-Example")
        .build()
    // RequestLine()
    let response: Response = client.newCall(request).execute()
    println(response.getMessage())
    // if("GET /index.html HTTP/1.1"==RequestLine.get(request)) {
    //     return 0
    // } else {
    //     return 1
    // }
}