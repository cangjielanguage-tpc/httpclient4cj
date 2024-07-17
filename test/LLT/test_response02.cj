// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.io.*
main (){
    let response = Response.builder().build()
    try {
        response.getHeaders().get("Transfer-Encoding")
        let header = response.getHeader("Connection", "close")
    } catch(e: Exception) {
        println("case pass")
    }
    return 0
}

