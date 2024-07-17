// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*


main() {
    let arr = ByteArrayStream()
    arr.write("123\n".toArray())
    let buf = OkBuffer(arr)
    try{
        let s1 = buf.readUtf8LineStrict()

    } catch (e: Exception) {
        return 0
    }
    return 1
}
