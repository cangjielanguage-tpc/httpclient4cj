// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let body = RealRequestBody.create(MediaType.get("application/json"), "123")
    try {
        Request.builder().put(body).patch(body).delete(body).get().head().build()
    } catch(e :Exception) {
        return 1
    }
    return 0
}

