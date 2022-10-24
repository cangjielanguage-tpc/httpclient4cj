// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example").build()
    RequestLine()
    let response: Response = client.newCall(request).execute()
    println(response.getMessage())
    if("GET /index.html HTTP/1.1"==RequestLine.get(request)) {
        return 0
    } else {
        return 1
    }
}