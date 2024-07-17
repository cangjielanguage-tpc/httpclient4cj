// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*
main() {
    var byteArrayStream = ByteArrayStream(10)
    var okbuffer = OkBuffer(byteArrayStream)
    byteArrayStream.write("hello world".toArray())

    if (okbuffer.indexOf(108,4,11) == 9) {
        return 0
    }
    return 1
}

