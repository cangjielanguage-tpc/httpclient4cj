// DEPENDENCE: ./body.text
// DEPENDENCE: ./gzip.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import collection.*
from std import time.*
from std import runtime.*
from std import io.*
from compress import zlib.*
from std import fs.*
main() {
    var srcFile: File = File("./body.text", OpenOption.Open(true, true))
    var srcFile2: File = File("./gzip.text", OpenOption.Open(true, true))
    var cotps = CompressOutputStream(srcFile2, wrap:GzipFormat, bufLen: 4096)
    cotps.write(srcFile.readToEnd())
    cotps.flush()
    cotps.close()
    srcFile2.close()

    var srcFile3: File = File("./gzip.text", OpenOption.Open(true, true))
    var gzip = OkGzipSource(OkBuffer(srcFile3))
    let base  =  ByteArrayStream()

    var gzipInt64 = gzip.read(base, 100)
    srcFile3.close()
    println("===============================")
    println(String.fromUtf8(base.readToEnd()))
}

