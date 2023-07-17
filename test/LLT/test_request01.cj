// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*

main (){
    let originalRequest = Request.builder().build()
    originalRequest.getUrl()
    originalRequest.getMethod()
    return 0
}
