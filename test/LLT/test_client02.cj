// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*
main (){
    let client = OkHttpClient.builder().build()
    let interceptor = ConnectInterceptor(client)
    let clientbuild = OkHttpClient.builder()
    clientbuild.addInterceptor(interceptor)
    return 0
}

