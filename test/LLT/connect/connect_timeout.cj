// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().connectTimeout(Duration.millisecond(10000)).
        readTimeout(Duration.millisecond(100000)).writeTimeout(Duration.millisecond(100000)).build()
    let request: Request = Request.builder().url("https://www.jd.com")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}