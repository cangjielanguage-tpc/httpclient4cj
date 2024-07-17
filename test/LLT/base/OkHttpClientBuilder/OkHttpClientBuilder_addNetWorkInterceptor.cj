// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.http.*

main (){
    let client = HttpClient.builder()
    .followRedirects(true)
    .retryOnConnectionFailure(true)
    .connectionPool(Option<ConnectionPool>.None)
    .build()

    if (client.getFollowRedirects() == true && client.getRetryOnConnectionFailure() == true) {
        return 0
    } else {
        return 1
    }
}

