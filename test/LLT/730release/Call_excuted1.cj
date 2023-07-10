// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import sync.sleep

var asyncCount = 0;
main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request2: Request = Request.builder().url("http://44.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let async = client.newCall(request2)
    async.enqueue(MyCallbacks())
    try {
        async.enqueue(MyCallbacks())
    } catch (e: Exception) {
        return 0
    }
    sleep(Duration.second)
    return 1
}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println(e.message)
        asyncCount = 1;
    }
    public func onResponse(call: Call,  response: Response): Unit{
        response.getCacheControl()
        response.close()
        println("success")
    }
}