// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*

//覆盖设置cookie对报文的影响，setCookie响应报文无返回
main() {
   //http://127.0.0.1:${port}/1234
    //http://www.zhihu.com
    //http://www.baidu.com/index.html
    //https://www.zhihu.com/signin?next=%2F
    //"https://restapi.amap.com/v3/weather/weatherInfo?city=深圳&key=13eb58f5884f9749287abbead9c65"
    //http://www.weather.com.cn/data/sk/101010100.html
    //http://wjhsh.net/Jimc-p-10250861.html

    //setCookie = _zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=/; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.zhihu.com
    // setCookie = _xsrf=287715ac-ba37-4b68-9311-666c13ba7705; path=/; domain=.zhihu.com
    //setCookie = KLBRSID=af132c66e9ed2b57686ff5c489976b91|1665456289|1665456289; Path=/
    let url: URL = URL.parse("http://www.weather.com.cn/data/sk/101010100.html")
    let jar = getSimpleCookieJar()
    jar.saveFromResponse(url, [Cookie("BD_HOME", "1"), Cookie("BD_UPN", "12314753")])
    let client: OkHttpClient= OkHttpClient.builder().cookieJar(jar)
    .build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)

    try{
        let response: okhttp.Response = call.execute()
        let arr = ByteArrayStream()
         if(client.getCookieJar().loadForRequest(url).size > 0) {
            return 0
         } else {
            return 1
         }

    }catch (e: Exception) {
        e.printStackTrace()
        return 1
    }
}