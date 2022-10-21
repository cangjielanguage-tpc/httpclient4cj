// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*

main() {
    let formBody = FormBody.builder()
            .add("username", "admin")
            .add("password", "123456")
            .add("host","%6D")
            .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://www.baidu.com")
                                    .method("POST", body: formBody)
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()

    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
         return 0

    }
}

