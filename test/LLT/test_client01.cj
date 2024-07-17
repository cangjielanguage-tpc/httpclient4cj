// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std. collection.*

main (){
    let client = HttpClient.builder().build()
    let originalRequest = Request.builder().build()
    client.newCall(originalRequest)
    client.getFollowRedirects()
    return 0
}

