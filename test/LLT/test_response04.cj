// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
main (){
    let response = Response.builder()
    let request = Request.builder().build()
    response.request(request)
    let protocol = Protocol.get("http/1.0")
    response.protocol(protocol)
    response.code(1)
    response.message("response message is exist")
    response.header("contentLength", "10")
    response.addHeader("Connection", "close")
    response.removeHeader("Connection")
    let ss: StringStream = StringStream("abcdefG")
    let body: ResponseBody = ResponseBody("text/html", 31946, ss)
    response.body(body)
    return 0
}

