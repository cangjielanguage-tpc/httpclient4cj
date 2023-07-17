// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*
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

