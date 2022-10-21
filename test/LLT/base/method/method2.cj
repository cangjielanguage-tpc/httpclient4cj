// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

main() {
    try {
    let request: okhttp.Request = okhttp.Request.builder()
        .method("POST").build()
    }catch(e :Exception) {
        return 0
    }
    return 1
}

