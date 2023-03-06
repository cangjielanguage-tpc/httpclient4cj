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


class MyInterceptor1<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
        okhttp_Chain_001.check1 = "MyInterceptor1 called "
        return chain.proceed(request)
    }
}
class MyInterceptor2<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
        okhttp_Chain_001.check2 = "MyInterceptor2 called "
        return chain.proceed(request)
    }
}
class MyInterceptor3<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        let request: okhttp.Request = chain.getRequest()
        let requestBuilder: okhttp.RequestBuilder  = request.newBuilder()
        let header: Header = request.getHeaders()
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
    func okhttp_Chain_001(): Unit {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let client: OkHttpClient= OkHttpClient.builder().addNetworkInterceptor(MyInterceptor1())
                                                    .addNetworkInterceptor(MyInterceptor2())
                                                    .addNetworkInterceptor(MyInterceptor3())
                                          .build()
    // let body: okhttp.RequestBody = okhttp.RequestBody("Media-Type", "text/html")
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("GET")//加body
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    @Assert(check1,"MyInterceptor1 called ")
    @Assert(check2,"MyInterceptor2 called ")
    @Assert(check3,"MyInterceptor3 called ")
    }
}