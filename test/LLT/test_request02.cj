// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*

main (){
    let originalRequest = Request.builder()
    try {
        let request = originalRequest.url("")
    } catch(e: Exception) {
        println("case pass")
    }
    originalRequest.url("http://127.0.0.1:1011/ff")
    originalRequest.header("Connection", "close")
    originalRequest.method("post")
    return 0
}
