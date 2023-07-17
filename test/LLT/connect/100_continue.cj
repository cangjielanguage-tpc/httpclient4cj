// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

//100-continue请求， 如果服务端返回100，继续请求
main() {
    let client: HttpClient= HttpClient.builder()
                                          .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://okhttp:50067/anything")
                                    .header("Expect", "100-continue")
                                    .method("POST", body: RealRequestBody.create(MediaType.get("application/json"), "123"))
                                    .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody()?.getString()??"")
}

