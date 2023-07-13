// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    try {
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .method("GET", body: RealRequestBody.create(MediaType.get("application/json"), "123")).build()
    }catch(e :Exception) {
        return 0
    }
    return 1
}

