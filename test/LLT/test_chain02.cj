// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*
main (){
    let client = OkHttpClient.builder().build()
    let conn = ConnectInterceptor(client)
    var interceptors: ArrayList<Interceptor> = ArrayList<Interceptor>()
    interceptors.append(conn)
    let originalRequest = Request.builder().build()
    let call = RealCall.newRealCall(client, originalRequest, true)
    var chain = Chain(interceptors, 1, originalRequest, call)
    try {
        let str = chain.proceed(originalRequest)
    } catch(e: Exception) {
        println("case pass")
    }
    return 0
}

