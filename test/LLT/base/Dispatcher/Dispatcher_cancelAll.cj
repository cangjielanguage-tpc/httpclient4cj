// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*

main () {
    let d = Dispatcher()
    d.setIdleCallback(Option<()-> Unit>.None)
    d.setMaxRequests(5)
    d.setMaxRequestsPerHost(5)
    HttpException("Test")
    let client = OkHttpClient.builder()
    .dispatcher(d).build()
    let request: okhttp.Request = okhttp.Request.builder()
    .url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .body(RequestBody("text/plain","TEST"))
    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(d.getMaxRequests())
    println(d.getMaxRequestsPerHost())
    d.cancelAll()
    println(d.queuedCallsCount())
    return 0
}
