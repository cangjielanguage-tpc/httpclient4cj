// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.sync.sleep

main() {
    let client: HttpClient= HttpClient.builder().build()
    client.getDispatcher().setIdleCallback( { => println("===================di idle======================")})
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    client.newCall(request).enqueue(MyCallbacks())
    sleep(Duration.second)
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