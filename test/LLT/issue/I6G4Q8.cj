// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*
main() {
   var byteArrayStream = ByteArrayStream(10)
   var okbuffer = OkBuffer(byteArrayStream)
   byteArrayStream.write("华为\n中国".toArray())
   try{
       okbuffer.readUtf8Line(4)
   } catch (e:Exception){
        return 0
   }
   return 1
}

