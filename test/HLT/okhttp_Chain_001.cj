// 3rd_party_lib:httpclient4cj/build/httpclient4cj
// 3rd_party_lib:httpclient4cj/ci_lib/cryptocj


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

class MyInterceptor1<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        request.newBuilder()
        request.getHeaders()
        okhttp_Chain_001.check1 = "MyInterceptor1 called "
        return chain.proceed(request)
    }
}
class MyInterceptor2<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        request.newBuilder()
        request.getHeaders()
        okhttp_Chain_001.check2 = "MyInterceptor2 called "
        return chain.proceed(request)
    }
}
class MyInterceptor3<: Interceptor {
    
    public func intercept(chain: Chain): httpclient4cj.Response {
        let request: httpclient4cj.Request = chain.getRequest()
        request.newBuilder()
        request.getHeaders()
        okhttp_Chain_001.check3 = "MyInterceptor3 called "
        return chain.proceed(request)
    }
}
@Test
public class okhttp_Chain_001{
    static var check1:String = "" 
    static var check2:String = "" 
    static var check3:String = "" 

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
    func okhttp_Chain_001(): Unit {
    spawn {
        serve()
    }
    sleep(Duration.second)
    let client: HttpClient= HttpClient.builder().addNetworkInterceptor(MyInterceptor1())
                                                    .addNetworkInterceptor(MyInterceptor2())
                                                    .addNetworkInterceptor(MyInterceptor3())
                                          .build()
    // let body: httpclient4cj.RequestBody = httpclient4cj.RequestBody("Media-Type", "text/html")
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")//加body
                                    .build()
    client.newCall(request).execute()
    @Assert(check1,"MyInterceptor1 called ")
    @Assert(check2,"MyInterceptor2 called ")
    @Assert(check3,"MyInterceptor3 called ")
    }
}