// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*

var port: UInt16 = 0
//覆盖设置cookie对报文的影响，setCookie HttpOnly
main() {


    //Max-Age存在时,以max-Age优先，表示失效的相对时间，单位为秒
    //setCookie = aliyungf_tc=4fcc6359a2084101dc82c15f3955c6126766c5b21109fbe4a39616f4192ba0e2; Path=/; HttpOnly
    //setCookie = acw_tc=0a324fb516657393236678577e76052a825b3fafab5db4e52bcc6530fe5a0e;path=/;HttpOnly;Max-Age=1800
    //setCookie = KLBRSID=af132c66e9ed2b57686ff5c489976b91|1665456289|1665456289; Path=/
    let url: URL = URL.parse("https://blog.51cto.com/u_15067225/2604109")
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