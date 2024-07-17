// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.fs.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body1.txt", arr)
    File.writeTo("./body2.txt", arr)
    let body1 = RealRequestBody.create(MediaType.get("text/plain"), File("./body1.txt", OpenOption.Open(true, false)))
    let body2 = RealRequestBody.create(MediaType.get("text/plain"), File("./body2.txt", OpenOption.Open(true, false)))
    let mu = MultipartBody.builder()
        .addFormDataPart("name", "huluwa")
        .addFormDataPart("age", "18")
        .addFormDataPart("file1", "body1.txt", body1)
        .addFormDataPart("file2", "body2.txt", body2)
        .build()
    let request = Request.builder().url("http://127.0.0.1:50060").post(mu).build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body1.txt")
    File.delete("./body2.txt")
}