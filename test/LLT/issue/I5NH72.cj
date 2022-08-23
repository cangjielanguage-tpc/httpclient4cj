// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let call = client.newCall(request)
    let response: Response = call.execute()
    println(call.isExecuted())
    println(call.isCanceled())
    if(call.isExecuted() == true && call.isCanceled() == false ) {
        return  0
    } else {
        return -1
    }

}