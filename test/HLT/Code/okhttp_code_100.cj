// 3rd_party_lib:okhttp/build/okhttp

from std import unittest.*
from std import unittest.testmacro.*
from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*  

class MyInterceptor<: Interceptor {
    
    public func intercept(chain: Chain): okhttp.Response {
        let request: okhttp.Request = chain.getRequest()
        var response:okhttp.Response = chain.proceed(request)
        return response.newBuilder().code(100).build()
    }
}

@Test
public class okhtttp_code_100{
    var port: UInt16 = 0
    func serve(){
        let hd = http.Route()
        hd.handle("/1235", { rws: ResponseWriteStream, req: http.Request =>
            // rws.writeStatusCode(HttpStatusCode.STATUS_CONTINUE)
            let resp = "".toUtf8Array()
            rws.write(resp)
            return
        })
        let server = http.Server(hd)
        let socket = SocketServer(SocketNet.TCP, "0.0.0.0", port)
        port = socket.port
        server.serve(socket) 
    }

    @TestCase
    func okhtttp_code_100(): Unit {
            
        spawn {
            serve()
        }
        sleep(1000*1000*1000)
        var code : Int64 = -1
        try{
            let client: OkHttpClient= OkHttpClient.builder().addNetworkInterceptor(MyInterceptor()).build()
            let request: okhttp.Request = okhttp.Request.builder()
                                            .url("http://127.0.0.1:${port}/1235")
                                            .method("GET")
                                            .build()
            let call = client.newCall(request)
            let response: okhttp.Response = call.execute()
            code = response.getCode() 
        } catch (e:Exception){
            println(e.message)
        }
        @Assert(code, Int64(100))
    }

}

