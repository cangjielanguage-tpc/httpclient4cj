// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*
main() {
    var byteArrayStream = ByteArrayStream(10)
    byteArrayStream.write("hello world".toArray())
    var okbuffer = OkBuffer(byteArrayStream)
    okbuffer.close()

    if (okbuffer.isClosed()) {
        return 0
    }
    return 1
}

