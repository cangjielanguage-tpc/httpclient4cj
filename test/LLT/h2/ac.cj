// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*


main (){
    let client = OkHttpClient.builder()
    .protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])).build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: okhttp.Response = client.newCall(request).execute()

    if(response.getBody().getOrThrow().getString() == "hello") {
        return 0
    } else {
        return 1
    }
}
