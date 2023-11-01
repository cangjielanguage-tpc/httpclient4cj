// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*

main() {
    let arr = ByteArrayStream()
    arr.write("123\n".toArray())
    let buf = OkBuffer(arr)
    let s1 = buf.readUtf8Line()
    if (s1 == "123") {
        return 0
    } else {
        return 1
    }
}

