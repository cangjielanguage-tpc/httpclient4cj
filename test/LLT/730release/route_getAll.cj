// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.collection.*
import std.socket.*

main() {
    let client: HttpClient= HttpClient.builder().build()
    let request: Request = Request.builder()
        .url("http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response: Response = client.newCall(request).execute()
    let response2: Response =client.newCall(request).execute()
}