// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*


main() {
    let arr = ByteArrayStream()
    arr.write("123\n".toUtf8Array())
    let buf = OkBuffer(arr)
    try{
        let s1 = buf.readUtf8LineStrict()

    } catch (e: Exception) {
        return 0
    }
    return 1
}
