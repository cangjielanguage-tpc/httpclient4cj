// DEPENDENCE: ./body.text
// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import fs.*
from std import log.*

//使用http2,不response关闭,可以连接多路复用,对于相同请求,不需要创建新的连接,期望连接池连接数为1
main() {
    let body = RealRequestBody.create(
        MediaType.get("application/json"), 
        File("./body.text", OpenOption.Open(true, false))
    )
    let mu = MultipartBody.builder()
        .addFormDataPart("name", "lyk")
        .addFormDataPart("age", "18")
        .addFormDataPart("file1", "body.text", body)
        .build()
    let client = HttpClient.builder()
        .protocols(ArrayList<String>([httpclient4cj.Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]))
        .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://127.0.0.1:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/put")
        .method("POST", body: mu)
        .header(Header())
        .header("User-Agent", "OkHttp-Example")
        .build()

    for (_ in 0..10) {
        let _: httpclient4cj.Response = client.newCall(request).execute()
    }
    if (client.getConnectionPool().getOrThrow().connectionCount() == 1) {
        return 0
    } else {
        return 1
    }
}
