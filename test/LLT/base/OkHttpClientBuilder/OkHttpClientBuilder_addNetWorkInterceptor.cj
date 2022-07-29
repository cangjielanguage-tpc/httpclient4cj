// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*

main (){
    let client = OkHttpClient.builder()
    .followRedirects(true)
    .retryOnConnectionFailure(true)
    .connectionPool(Option<ConnectionPool>.None)
    .cookieJar(CookieJar())
    .build()

    if (client.getFollowRedirects() == true && client.getRetryOnConnectionFailure() == true) {
        return 0
    } else {
        return 1
    }
}

