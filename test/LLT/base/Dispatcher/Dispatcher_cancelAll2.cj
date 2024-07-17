// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.sync.sleep

main() {
    let client: HttpClient = HttpClient.builder().build()
    let request: Request = Request.builder()
        .url("http://36.152.44.95/index.html")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let call1 = client.newCall(request)
    call1.execute()
    call1.clone().enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    client.getDispatcher().cancelAll()
    sleep(Duration.second)
    return client.getDispatcher().runningCallsCount()
}

public class MyCallbacks <: Callback {
    public func onFailure(call: Call, e: Exception): Unit {
        //println(e.message)
        println("FAILED")
    }
    public func onResponse(call: Call, response: Response): Unit {
        response.getCacheControl()
        response.close()
        println("success")
    }
}
