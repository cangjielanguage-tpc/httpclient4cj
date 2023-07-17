// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*

from net import http.*
from std import io.*
from std import time.*
from std import socket.*
from std import fs.*


var port: UInt16 = 0
main() {

    let cache: Cache = Cache("./cacheccccccc", 10 * 1024 * 1024)
    let client: HttpClient= HttpClient.builder().cache(cache).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    //.url("http://127.0.0.1:8080/cangjie_test-1.0-SNAPSHOT/hello")
                                    .url("http://okhttp:50067/anything")
                                    .method("GET")
                                    .build()
    println("first =====================")
    let res = client.newCall(request).execute()
    let s = res.getBody().getOrThrow().getString()
    println(s)
    println("second cache =====================")

    let b = client.newCall(request).execute()
    println(b)
    return 0
}

