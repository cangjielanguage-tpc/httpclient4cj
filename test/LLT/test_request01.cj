// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main (){
    let originalRequest = Request.builder().build()
    originalRequest.getUrl()
    originalRequest.getMethod()
    return 0
}
