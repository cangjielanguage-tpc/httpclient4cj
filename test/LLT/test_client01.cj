// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import  collection.*

main (){
    let client = HttpClient.builder().build()
    let originalRequest = Request.builder().build()
    client.newCall(originalRequest)
    client.getFollowRedirects()
    return 0
}

