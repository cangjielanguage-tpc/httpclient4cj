// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import collection.*
from std import socket.*

main() {
    let client: HttpClient= HttpClient.builder().build()
    let request: Request = Request.builder()
        .url("http://127.0.0.1:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello")
        .header("User-Agent", "OkHttp-Example")
        .build()
    let response: Response = client.newCall(request).execute()
    let response2: Response =client.newCall(request).execute()
}