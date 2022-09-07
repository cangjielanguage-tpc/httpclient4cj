// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    client.newCall(request).enqueue(MyCallbacks())
    sleep(1000*1000*1000)
    println(client.getDispatcher().runningCallsCount())
}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println(e.message)
    }
    public func onResponse(call: Call,  response: Response): Unit{
        response.getCacheControl()
        response.close()
        println("success")
    }
}