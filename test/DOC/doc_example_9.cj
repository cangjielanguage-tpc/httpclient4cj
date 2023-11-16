// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from encoding import url.*
from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let url: URL = URL.parse("http://127.0.0.1:50060")
    let jar = getSimpleCookieJar()
    let client: HttpClient = HttpClient.builder()
        .cookieJar(jar)
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    for (cookie in client.getCookieJar().loadForRequest(url)) {
        println(cookie.toSetCookieString())
    }
    return 0
}