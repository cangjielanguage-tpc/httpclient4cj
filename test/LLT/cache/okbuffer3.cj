// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*

main() {
    let arr = ByteArrayStream()
    arr.write("12345\n345\r\n".toUtf8Array())
    let buf = OkBuffer(arr)

    let s1 = buf.readUtf8LineStrict()
    if (s1 == "12345\n345") {
        return 0
    } else {
        return 1
    }
}
