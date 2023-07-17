// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient= HttpClient.builder()
                                          .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("https://baidu.com")
                                    .method("POST", body: RealRequestBody.create(
                                        MediaType.get("application/json"), "123"))
                                    .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody()?.getString()??"")
}

