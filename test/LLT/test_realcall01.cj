// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main (){
    let client = OkHttpClient.builder().build()
    let originalRequest = Request.builder().build()
    let realcall =  RealCall.newRealCall(client, originalRequest, false)
    realcall.getRequest()
    realcall.cancel()
    realcall.isExecuted()
    realcall.isCanceled()
    realcall.timeout()
    realcall.clone()
    return 0
}