// DEPENDENCE: ./body.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.fs.*
import net.http.*

main() {
    let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))
    let header = Header()
    header.add("test","123")
    let mu = MultipartBody.builder().
    setType(MultipartBody.FORM).
    addFormDataPart("name", "lyk").
    addFormDataPart("age", "18").
    addPart(body).
    addPart(header,body).build()
    let arr = Array<Byte>(mu.getContentLength(), item: 0)
    mu.get().read(arr)
    println(String.fromUtf8(arr))
    if (mu.getType().toString() == "multipart/form-data") {
        return 0
    } else {
        return 1
    }

}

