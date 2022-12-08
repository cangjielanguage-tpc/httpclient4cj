// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*

main() {
    let formBody = FormBody.builder()
            .add("username", "admin")
            .add("password", "123456")
            .add("host","%6D")
            .build()
    let input = formBody.get()
    let arr = Array<Byte>(input.length, item:0)
    input.read(arr)
    let s = String.fromUtf8(arr)
    if( s == "username=admin&password=123456&host=%6D"
        && formBody.contentType().getOrThrow().toString() == "application/x-www-form-urlencoded"
        && formBody.getContentLength() == s.size
        ) {
        return 0
    } else {
        return 1
    }
}

