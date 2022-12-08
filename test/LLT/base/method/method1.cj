// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder()
                                          .build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://www.baidu.com")
                                    .method("POST", body: RealRequestBody.create(
                                        MediaType.get("application/json"), "123"))
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.getBody()?.getString()??"")
}

