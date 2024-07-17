// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.sync.sleep

var asyncCount = 0;
main() {
    let client: HttpClient= HttpClient.builder().build()
    let request2: Request = Request.builder().url("http://44.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let async = client.newCall(request2)
    async.enqueue(MyCallbacks())
    sleep(11*Duration.second)
    if(asyncCount == 1) {
        return 0
    } else {
        return 1
    }
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