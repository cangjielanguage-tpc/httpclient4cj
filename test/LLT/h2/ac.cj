// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*

main() {
    let client = HttpClient.builder()
        .protocols(ArrayList<String>([httpclient4cj.Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]))
        .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()

    if (response.getBody().getOrThrow().getString() == "hello") {
        return 0
    } else {
        return 1
    }
}
