// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import collection.*
from std import socket.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().protocols(
         ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])).build()
    let request: Request = Request.builder().
        url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: Response = client.newCall(request).execute()
    println(String(toArray(response.getBody().getOrThrow().getSource().readToEnd())))
}