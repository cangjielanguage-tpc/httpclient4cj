// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std. collection.*
main (){
    let client = HttpClient.builder().build()
    let interceptor = ConnectInterceptor(client)
    let clientbuild = HttpClient.builder()
    clientbuild.addInterceptor(interceptor)
    return 0
}

