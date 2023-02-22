// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
main() {
    var byteArrayStream = ByteArrayStream(10)
    var okbuffer = OkBuffer(byteArrayStream)
    byteArrayStream.write("hello world".toUtf8Array())

    if (okbuffer.indexOf(108,4,11) == 9) {
        return 0
    }
    return 1
}

