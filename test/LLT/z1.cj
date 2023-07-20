// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from encoding import url.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let client: HttpClient = HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://imgsrc.baidu.com/forum/w%3D580/sign=eed1753686d6277fe9123230183a1f63/9dcd7cd98d1001e950d1f582b90e7bec55e7974b.jpg")
        .build()
    var response: httpclient4cj.Response = client.newCall(request).execute()
    // let res = response.getBody().getOrThrow().getString()
    // println(res)
    var response_heads: Header = response.getHeaders()
    for ((nm,vl) in response_heads) {
        println(nm)
        println(vl)
    }
    return 0
}
