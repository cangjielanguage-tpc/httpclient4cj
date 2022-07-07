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
    var chain = Chain(interceptors, Transmitter(client, call),  0, originalRequest, call, Option<Exchange>.None,
    client.getConnectTimeout(), client.getReadTimeout(), client.getWriteTimeout())
    return 0
}

