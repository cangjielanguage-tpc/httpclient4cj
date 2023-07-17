// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import  collection.*
main (){
    let client = HttpClient.builder().build()
    let interceptor = ConnectInterceptor(client)
    let clientbuild = HttpClient.builder()
    clientbuild.addInterceptor(interceptor)
    return 0
}

