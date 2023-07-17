// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*
main() {
   var byteArrayStream = ByteArrayStream(10)
   var okbuffer = OkBuffer(byteArrayStream)
   byteArrayStream.write("华为\n中国".toUtf8Array())
   try{
       okbuffer.readUtf8LineStrict(10)
   } catch (e:Exception){
        return 0
   }
   return 1
}

