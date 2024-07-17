// DEPENDENCE: ../../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
import std.io.*
import httpclient4cj
import httpclient4cj.*
import net.http.*
import std.socket.*
import std.collection.*
import encoding.url.*
import net.tls.*

//setCookie响应报文属性有expires， path， domian的解析
main() {
    // setCookie = _zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.zhihu.com
    // setCookie = _xsrf=287715ac-ba37-4b68-9311-666c13ba7705; path=/; domain=.zhihu.com
    // setCookie = KLBRSID=af132c66e9ed2b57686ff5c489976b91|1665456289|1665456289; Path=/
    let url: URL = URL.parse("https://www.zhihu.com")
    let client: HttpClient = HttpClient.builder().cookieJar(getSimpleCookieJar()).build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)

    try {
        let response: httpclient4cj.Response = call.execute()
        println(response.toString())
        let arr = client.getCookieJar().loadForRequest(url)
        println("1.2 ${arr |> map{c:Cookie=>c.toSetCookieString()} |> collectString<String>(delimiter:" ")}")
        if (arr.size > 0) {
            return 0
        } else {
            return 1
        }
    } catch (e: Exception) {
        e.printStackTrace()
        return 2
    }
}
