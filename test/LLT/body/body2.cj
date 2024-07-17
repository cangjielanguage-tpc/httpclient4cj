// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*

main() {
    let formBody = FormBody.builder()
            .add("username", "admin")
            .add("password", "123456")
            .add("host","%6D")
            .build()
    let input = formBody.get()
    let arr = Array<Byte>(1024, item:0)
    let len = input.read(arr)
    let s = String.fromUtf8(arr[..len])
    println("${s} ${formBody.contentType().getOrThrow().toString()} ${formBody.getContentLength()}")
    if( s == "username=admin&password=123456&host=%256D"
        && formBody.contentType().getOrThrow().toString() == "application/x-www-form-urlencoded"
        && formBody.getContentLength() == s.size
        ) {
        return 0
    } else {
        return 1
    }
}

