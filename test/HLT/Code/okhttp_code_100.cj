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
import std.sync.sleep

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        var response:httpclient4cj.Response = chain.proceed(request)
        return response.newBuilder().code(100).build()
    }
}

@Test
public class okhtttp_code_100{
    var port: UInt16 = 0
    func serve(){
        let serverSocket = TcpServerSocket(bindAt: 0)
        let server = ServerBuilder().listener(serverSocket).build()
        server.distributor.register("/1235", { httpContext =>
            // httpContext.responseBuilder.status(HttpStatusCode.STATUS_CONTINUE)
            let resp = "".toArray()
            httpContext.responseBuilder.body(resp)
            return
        })
        spawn{ server.serve() }
        sleep(Duration.second)
        port = serverSocket.localAddress.port
    }

    @TestCase
    func okhtttp_code_100(): Unit {
        serve()
        var code : Int64 = -1
        try{
            let client: HttpClient= HttpClient.builder().addNetworkInterceptor(MyInterceptor()).build()
            let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                            .url("http://127.0.0.1:${port}/1235")
                                            .method("GET")
                                            .build()
            let call = client.newCall(request)
            let response: httpclient4cj.Response = call.execute()
            code = response.getCode() 
        } catch (e:Exception){
            println(e.message)
        }
        @Assert(code, Int64(100))
    }

}

