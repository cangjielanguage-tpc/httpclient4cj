// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    try {
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .method("POST").build()
    }catch(e :Exception) {
        return 0
    }
    return 1
}

