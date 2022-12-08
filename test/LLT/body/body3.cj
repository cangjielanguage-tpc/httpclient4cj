// DEPENDENCE: ./body.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import fs.*

main() {
    let body = RealRequestBody.create(MediaType.get("application/json"),File("./body.text",OpenOption.Open(true,false)))
    let arr = Array<Byte>(body.getContentLength(), item: 0)
    body.get().read(arr)
    println("==============================================================-==================================")
    println(body.getContentLength())
    println(String.fromUtf8(arr))
    if (body.getContentLength() == 11 && String.fromUtf8(arr) == "i am a body") {
        return 0
    } else {
        return 1
    }
}

