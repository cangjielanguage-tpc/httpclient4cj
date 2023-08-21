// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from encoding import url.*
from httpclient4cj import httpclient4cj.*
from net import tls.*
from std import collection.*
from std import time.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    // 需要用户自己配置CA证书验证公钥,如果不配置CA证书将不进行服务端证书校验,将使用不安全的连接
    // H2_PRIOR_KNOWLEDGE 使用明文http2协议, 不支持https
    // .protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]))
    // 使用apln协商协议,服务端响应支持的协议，list中前面的协议会被优先选择
    let client: HttpClient = HttpClient.builder()
        .tlsConfig(TlsClientConfig())
        .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(), Protocol.get("HTTP/1.1").toString()]))
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response)
    return 0
}