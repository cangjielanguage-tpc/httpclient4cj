// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
main (){
    let ss: StringStream = StringStream("abcdefG")
    let body: ResponseBody = ResponseBody(BufferStream(ss))
    body.getSource()
    return 0
}

