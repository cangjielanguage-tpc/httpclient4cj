// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder()
        .url("http://127.0.0.1:50060")
        .header("User-Agent", "Httpclient4cj-Example")
        .build()
    for (i in 0..5) {
        let async = client.newCall(request)
        async.enqueue(MyCallbacks())
    }
    sleep(Duration.second)
}
public class MyCallbacks <: Callback {
    public func onFailure(call: Call, e: Exception): Unit {
        println("fail, ${e.message}")
    }
    public func onResponse(call: Call, response: Response): Unit {
        println(response)
    }
}