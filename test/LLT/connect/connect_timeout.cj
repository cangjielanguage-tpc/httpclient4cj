// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.millisecond * 10000)
        .readTimeout(Duration.millisecond * 100000)
        .writeTimeout(Duration.millisecond * 100000)
        .build()
    let request: Request = Request.builder()
        .url("http://okhttp:${portTrans(50067)}/anything")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}
