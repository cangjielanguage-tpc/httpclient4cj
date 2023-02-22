// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
main() {
    var byteArrayStream = ByteArrayStream(10)
    byteArrayStream.write("hello world".toUtf8Array())
    var okbuffer = OkBuffer(byteArrayStream)
    okbuffer.close()

    if (okbuffer.isClosed()) {
        return 0
    }
    return 1
}

