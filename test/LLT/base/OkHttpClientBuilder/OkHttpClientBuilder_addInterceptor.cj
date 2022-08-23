// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*


main (){
    let client = OkHttpClient.builder().addNetworkInterceptor(MyInterceptor())
    .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(),Protocol.get("HTTP/1.1").toString()])).build()
    let request: okhttp.Request = okhttp.Request.builder().url("http://36.152.44.95/index.html")
    .header(Header())
    .header("User-Agent", "OkHttp-Example")
    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        let conn = chain.getConnection().getOrThrow()
        println(conn.getProtocol().toString())
        println(conn.getTransmitters().size())
        conn.getRoute()
        let add = Address(URL.parse("http://36.152.44.95/index.html"),
                            ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]),
                            Option<TlsClientConfig>.None
                        )
        add.getTlsConfig()
        conn.noExchanges()
        println(conn.isMultiplexed())
        conn.cancel()
        let request: okhttp.Request = chain.getRequest()
        let header: Header = request.getHeaders()
        let c = request.getCacheControl() ?? CacheControl.parse(header)
        println(c.toString())
        return okhttp.Response.builder().build()
    }
}