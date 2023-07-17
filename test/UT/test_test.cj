package httpclient4cj
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class TestCase {

    @TestCase
    public func caseA(): Unit {
        let client = HttpClient.builder().build()
        let retry = RetryAndFollowUpInterceptor(client)
        let conn = ConnectInterceptor(client)
        var interceptors: ArrayList<Interceptor> = ArrayList<Interceptor>()
        interceptors.append(conn)
        let originalRequest = Request.builder().build()
        let call = RealCall.newRealCall(client, originalRequest, true)
        var chain = Chain(interceptors, 0, originalRequest, call)
        let response = retry.intercept(chain)
    }

    @TestCase
    public func caseB(): Unit {
        let response = Response.builder()
        let request = Request.builder().build()
        response.request(request)
        let protocol = Protocol.get("http/1.0")
        response.protocol(protocol)
        response.code(1)
        response.message("response message is exist")
        response.header("contentLength", "10")
        response.addHeader("Connection", "close")
        response.removeHeader("Connection")
        let ss: StringStream = StringStream("abcdefG")
        let body: ResponseBody = ResponseBody(BufferStream(ss))
        response.body(body)
    }


}