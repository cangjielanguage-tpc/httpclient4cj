package okhttp

from std import io.*
from std import socket.*

var port: UInt16 = 12340

main() {
    var requestStream: StringStream = StringStream("")
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    client.newCall(request).enqueue(MyCallbacks())
    client.newCall(request).enqueue(MyCallbacks())
    sleep(1000*1000*1000)
    println(client.getDispatcher().runningCallsCount())
    ()
}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println(e.getMessage())
    }
    public func onResponse(call: Call,  response: Response): Unit{
        println("success")
    }
}





