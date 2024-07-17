// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
import encoding.url.*
import httpclient4cj
import httpclient4cj.*
import net.tls.*
import std.collection.*
import std.socket.*
import std.time.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    let client: HttpClient = HttpClient.builder()
        .eventListener(MyEventListener())
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}
class MyEventListener <: EventListener {
    public func callStart(call: Call): Unit {
        println("callStart!!!")
    }
    public func callEnd(call: Call): Unit {
        println("callEnd!!!")
    }
    public func dnsStart(call: Call, domainName: String): Unit {
        println("dnsStart!!!")
    }
    public func dnsEnd(call: Call, domainName: String, allRoutes: ArrayList<Route>): Unit {
        println("dnsEnd!!!")
    }
    public func connectStart(call: Call, socketAddress: SocketAddress): Unit {
        println("connectStart!!!")
    }
    public func connectEnd(call: Call, socketAddress: SocketAddress, protocol: Protocol): Unit {
        println("connectEnd!!!")
    }
    public func secureConnectStart(call: Call): Unit {
        println("secureConnectStart!!!")
    }
    public func secureConnectEnd(call: Call, tlsConfig: TlsClientConfig): Unit {
        println("secureConnectEnd!!!")
    }
    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException): Unit {
        println("connectFailed!!!")
    }
    public func requestHeadersStart(call: Call): Unit {
        println("requestHeadersStart!!!")
    }
    public func requestHeadersEnd(call: Call): Unit {
        println("requestHeadersEnd!!!")
    }
    public func requestBodyStart(call: Call): Unit {
        println("requestBodyStart!!!")
    }
    public func requestBodyEnd(call: Call, byteCount: Int64): Unit {
        println("requestBodyEnd!!!")
    }
    public func requestFailed(call: Call, e: HttpException): Unit {
        println("requestFailed!!!")
    }
    public func responseHeadersStart(call: Call): Unit {
        println("responseHeadersStart!!!")
    }
    public func responseHeadersEnd(call: Call, response: Response): Unit {
        println("responseHeadersEnd!!!")
    }
    public func responseBodyStart(call: Call): Unit {
        println("responseBodyStart!!!")
    }
    public func responseBodyEnd(call: Call, byteCount: Int64): Unit {
        println("responseBodyEnd!!!")
    }
    public func responseFailed(call: Call, e: HttpException): Unit {
        println("responseFailed!!!")
    }
}