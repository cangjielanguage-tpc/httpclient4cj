// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*

main () {
    let d = Dispatcher()
    d.setIdleCallback(Option<()-> Unit>.None)
    d.setMaxRequests(5)
    d.setMaxRequestsPerHost(5)
    HttpException("Test")
    let client = HttpClient.builder()
    .dispatcher(d).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
    .url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(d.getMaxRequests())
    println(d.getMaxRequestsPerHost())
    d.cancelAll()
    println(d.queuedCallsCount())
    return 0
}
