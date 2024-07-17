// 3rd_party_lib:httpclient4cj/build/httpclient4cj


import std.unittest.*
import std.unittest.testmacro.*
import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import net.http.*
import std.socket.*
import encoding.url.*
import net.tls.*
import std.core.*
import std.sync.sleep

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        let requestBuilder: httpclient4cj.RequestBuilder  = request.newBuilder()
        request.getHeaders()
        var response: httpclient4cj.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: httpclient4cj.ResponseBuilder = response.newBuilder().request(request)
        responseBuilder.prevResponse(Option<httpclient4cj.Response>.None)
        responseBuilder.sentRequestAtMillis(100)
        responseBuilder.receivedResponseAtMillis(200)
        func exception(): String{ "exception"}
        exception()
        return responseBuilder.build()
    }
}
@Test
public class okhttp_ResponseBuilder_002{

    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1234", { httpContext =>
            let resp = "Hello from /red".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }
    @TestCase
    func okhttp_ResponseBuilder_002(): Unit {
    serve()
    let client: HttpClient= HttpClient.builder().addNetworkInterceptor(MyInterceptor())
                                          .build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println("getPrevResponse:${response.getPrevResponse().toString()}")
    @Assert(response.getPrevResponse().toString(),"None")
    println("getSentRequestAtMillis:${response.getSentRequestAtMillis()}")
    @Assert(response.getSentRequestAtMillis(),100)
    println("getReceivedResponseAtMillis:${response.getReceivedResponseAtMillis()}")
    @Assert(response.getReceivedResponseAtMillis(),200)
    }
}