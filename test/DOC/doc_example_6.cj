// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import io.*

main() {
    let client: HttpClient = HttpClient.builder().build()
    let request = httpclient4cj.Request.builder().url("http://127.0.0.1:50060").post(MyRequestBody()).build()
    let response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}
class MyRequestBody <: RequestBody {
    public func contentType(): Option<MediaType> {
        return MediaType.parse("application/json")
    }
    public func getContentLength(): Int64 {
        // 声明的getContentLength -1，客户端拦截器默认添加"Transfer-Encoding", "chunked"头,使用ChunkedSink读取body
        return -1
    }
    public func writeTo(sink: Sink): Unit {
        // 每次调用write都会产生一个传输块
        sink.write("hello".toArray())
        sink.write("world".toArray())
    }
    public func get(): InputStream {
        return ByteArrayStream()
    }
}