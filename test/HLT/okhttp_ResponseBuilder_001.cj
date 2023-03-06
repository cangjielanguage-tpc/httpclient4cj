// 3rd_party_lib:okhttp/build/okhttp
// 3rd_party_lib:okhttp/ci_lib/cryptocj


from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
        var response: okhttp.Response =  chain.proceed(requestBuilder.build())
        let responseBuilder: okhttp.ResponseBuilder = response.newBuilder().request(request)
        responseBuilder.header("name1","value1")
        responseBuilder.header("name1","value2")
        responseBuilder.addHeader("name3","value3")
        responseBuilder.addHeader("name4","value4")
        responseBuilder.removeHeader("name4")
        func exception(): String{ "exception"}
        return responseBuilder.build()
    }
}
@Test
public class okhttp_ResponseBuilder_001{

    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
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
    func okhttp_ResponseBuilder_001(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let client: OkHttpClient= OkHttpClient.builder().addNetworkInterceptor(MyInterceptor())
                                          .build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    func exception(): String{ "exception"}
    @Assert(response.getHeader("name1"),"value2")
    @Assert(response.getHeader("name3"),"value3")
    @Assert(response.getHeader("name4").getOrDefault(exception),"exception")
    }
}