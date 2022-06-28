// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
main (){
    let str = Util()
    let ss: StringStream = StringStream("a")
    let Stream = BufferStream(ss.delete(0,1))
    IOException()
    Util.closeQuietly(Stream)
    return 0
}

