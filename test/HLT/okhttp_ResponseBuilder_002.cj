// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/crypto4cj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep

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
        let hd = http.Route()
        hd.handle("/1234", { rws: ResponseWriteStream, req: http.Request =>
            req.url
            let resp = "Hello from /red".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket)
    }
    @TestCase
    func okhttp_ResponseBuilder_002(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)
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