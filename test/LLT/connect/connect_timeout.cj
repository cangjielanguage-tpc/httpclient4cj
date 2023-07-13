// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient= HttpClient.builder().connectTimeout(Duration.millisecond*10000).
        readTimeout(Duration.millisecond*100000).writeTimeout(Duration.millisecond*100000).build()
    let request: Request = Request.builder().url("http://okhttp:50067/anything")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}