// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*


main() {
    let arr = ByteArrayStream()
    arr.write("123\r\n234\n".toArray())
    let buf = OkBuffer(arr)

    let s1 = buf.readUtf8LineStrict()
    if(s1 == "123") {
        return 0
    }

    return 1
}
