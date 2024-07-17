// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import std.time.*
import encoding.url.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response.getBody().getOrThrow().getString())
}