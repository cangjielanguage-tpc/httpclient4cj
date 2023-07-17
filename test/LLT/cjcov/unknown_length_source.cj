from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient= HttpClient.builder().build()
    let request: Request = Request.builder().url("http://192.168.11.13:9913")
    .header("User-Agent", "OkHttp-Example").build()
    RequestLine()
    let response: Response = client.newCall(request).execute()
    println(response.getMessage())
    println(response.getBody().getOrThrow().getString())
}