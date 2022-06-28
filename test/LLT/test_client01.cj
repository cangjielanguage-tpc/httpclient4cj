// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*

main (){
    let client = OkHttpClient.builder().build()
    let originalRequest = Request.builder().build()
    client.newCall(originalRequest)
    client.getFollowRedirects()
    return 0
}

