// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder()
        .url("http://127.0.0.1:50060")
        .post(RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "{\"id\": \"123\"}"))
        .build()
    let response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}