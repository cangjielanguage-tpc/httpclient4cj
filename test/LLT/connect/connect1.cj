// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*

main() {
    var requestStream: StringStream = StringStream("")
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: Response = client.newCall(request).execute()
    //println(response.getBody().getOrThrow().getSource().toString())
}