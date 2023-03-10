// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import time.*

//100-continue请求， 如果服务端返回100，继续请求
main() {
    let client: OkHttpClient= OkHttpClient.builder()
                                          .build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("https://httpbin.org/anything")
                                    .header("Expect", "100-continue")
                                    .method("POST", body: RealRequestBody.create(MediaType.get("application/json"), "123"))
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.getBody()?.getString()??"")
}

