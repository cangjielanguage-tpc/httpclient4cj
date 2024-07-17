// DEPENDENCE: ./body.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.fs.*

main() {
    let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))
    let mu = MultipartBody.builder().
    addFormDataPart("name", "lyk").
    addFormDataPart("age", "18").
    addFormDataPart("file1", "body.text", body).build()
    let arr = Array<Byte>(mu.getContentLength(), item: 0)
    mu.get().read(arr)
    println(String.fromUtf8(arr))


    mu.getBoundary()
    mu.getParts()
    if (mu.getType().toString() == "multipart/mixed") {
        return 0
    } else {
        return 1
    }

}

