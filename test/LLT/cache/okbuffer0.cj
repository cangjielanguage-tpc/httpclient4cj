// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*

main() {
    let arr = ByteArrayStream()
    arr.write("123\n".toUtf8Array())
    let buf = OkBuffer(arr)
    let s1 = buf.readUtf8Line()
    if (s1 == "123") {
        return 0
    } else {
        return 1
    }
}

