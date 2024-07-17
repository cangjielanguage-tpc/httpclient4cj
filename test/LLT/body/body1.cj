// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*

main() {
    let formBody = FormBody.builder()
        .add("username", "admin")
        .add("password", "123456")
        .add("host","%6D")
        .build()
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://www.baidu.com")
        .method("POST", body: formBody)
        .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()

    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
        return 0
    }
}

