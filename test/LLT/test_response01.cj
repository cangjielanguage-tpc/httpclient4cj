// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*
main (){
    let response = Response.builder().build()
    let b = ByteArrayStream()
    b.write("abcdefG".toArray())
    let body: ResponseBody = ResponseBody("text/html", 31946, OkBuffer(b))
    response.getRequest()
    response.getProtocol()
    response.getCode()
    response.isSuccess()
    response.getMessage()
    response.getHeader("name")
    try {
        let header = response.getHeader("name")
        let header2 = response.getHeader("Connection", "close")
    } catch(e: Exception) {
        println("case pass")
    }
    response.getHeaders()
    response.getBody()
    response.isRedirect()
    response.toString()
    return 0
}

