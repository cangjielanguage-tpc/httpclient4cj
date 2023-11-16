// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import fs.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body.txt", arr)
    let file = File("./body.txt", OpenOption.Open(true, false))
    let body = RealRequestBody.create(MediaType.get("text/plain"), file)
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://127.0.0.1:50060")
        .post(body)
        .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body.txt")
}