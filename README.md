<div align="center">
<h1>OkHttp</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.35.6-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-86.8%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>介绍

OkHttp 是一个高效的 HTTP 客户端, 代码参考: https://github.com/square/okhttp/tree/parent-3.14.9

## 特性

- 🚀 支持HTTP/2，允许所有同一个主机地址的请求共享同一个 socket 连接

- 🌍 连接池减少请求延时

- 💪 缓存响应内容，避免一些完全重复的请求

## 路线

<p align="center">
<img src="./doc/assets/milestone.png" width="100%" >
</p>

## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 软件架构

## 架构图

<p align="center">
<img src="./doc/assets/framework.PNG" width="60%" >
</p>

## 源码目录

```shell
.
├── README.md
├── doc
│   ├── assets
│   ├── cjcov     
│   ├── feature_api.md  
│   ├── design.md  
│   ├── proposal.md
│   └── xxx_lib.md 
├── lib
│   └── libdns.so
├── inclue
│   └── dns.c
├── src
│   └── okhttp
│      ├── address.cj
│      ├── bridge_interceptor.cj
│      ├── cache_control.cj
│      ├── cache_control_builder.cj
│      ├── call.cj
│      ├── call_back.cj
│      ├── call_server_interceptor.cj
│      ├── connect_interceptor.cj
│      ├── cookie.cj
│      ├── cookie_jar.cj
│      ├── dispatcher.cj
│      ├── error_code.cj
│      ├── event_listener.cj
│      ├── exception.cj
│      ├── exchange_codec.cj
│      ├── exchange_codec2.cj
│      ├── exchange_finder.cj
│      ├── form_body.cj
│      ├── hpack_config.cj
│      ├── hpack_decoder.cj
│      ├── hpack_encoder.cj
│      ├── hpack_tables.cj
│      ├── http2_connection.cj
│      ├── http2_stream.cj
│      ├── http2_writer.cj
│      ├── http2_reader.cj
│      ├── http_method.cj
│      ├── huffman.cj
│      ├── huffman_util.cj
│      ├── chain.cj
│      ├── interfaces.cj
│      ├── multipart_body.cj
│      ├── ok_buffer.cj
│      ├── ok_gzip_source.cj
│      ├── ok_http_client.cj
│      ├── ok_http_client_builder.cj
│      ├── ok_socket.cj
│      ├── protocol.cj
│      ├── queue.cj
│      ├── real_connection.cj
│      ├── real_connection_pool.cj
│      ├── request.cj
│      ├── request_body.cj
│      ├── request_builder.cj
│      ├── request_line.cj
│      ├── response.cj
│      ├── response_body.cj
│      ├── response_builder.cj
│      ├── retry_and_follow_up_interceptor.cj
│      ├── route.cj
│      ├── route_database.cj
│      ├── route_selector.cj
│      ├── settings.cj
│      ├── sink.cj
│      ├── socket_ffi.cj
│      ├── source.cj
│      ├── status_line.cj
│      ├── transmitter.cj
│      └── util.cj
└── test   
    ├── HLT
    ├── LLT
    └── UT
```
- `lib`依赖 c 库的dns解析接口的动态链接文件
- `clude` c代码目录
- `doc`是库的设计文档、提案、库的使用文档、LLT 覆盖报告 ( 由于未支持服务端的对接,部分拦截器连接后处理逻辑暂时无法覆盖)
- `src`是库源码目录
- `test`是存放测试用例，包括 HLT 用例、LLT 用例和 UT 用例

## 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 编译执行

### 编译

编译描述和具体shell命令

```shell
make
cpm update
cpm build
```

## 示例

注意：以下示例若在本地不成功，可能是 url 地址请求失败，请换成实际可用地址。

### 获取HttpClient对象并配置超时时间

```canjie
from okhttp import okhttp.*
from std import time.*

main (){
    let client: OkHttpClient= OkHttpClient.builder()
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000)).build()
}

```

### 同步 GET 请求方法示例

```canjie
from okhttp import okhttp.*
from std import time.*
from encoding import url.*

main() {
    let url = URL.parse("https://postman-echo.com/get?foo1=bar1&foo2=bar2")

    let client: OkHttpClient= OkHttpClient.builder()
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000))
    .build()

    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}

```
### 同步 Post 发送json字符串

```cangjie

from okhttp import okhttp.*
from std import time.*

main() {
   let client: OkHttpClient = OkHttpClient.builder()
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000))
    .build()
    let request = Request.builder()
                .url("https://postman-echo.com/post")
                .post(RealRequestBody.create(MediaType.get("application/json; charset=utf-8"),
                 "{\"id\": \"123\"}"))
                .build()
    let response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}
```

### 同步 Post 发送文件内容

```cangjie
from okhttp import okhttp.*
from std import time.*
from std import fs.*
main() {
   let client: OkHttpClient= OkHttpClient.builder()
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000))
    .build()

    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body.txt", arr)
    let file = File("./body.txt", OpenOption.Open(true, false))
    let body = RealRequestBody.create(MediaType.get("text/plain"),file)
    let request: okhttp.Request = okhttp.Request.builder()
                                  .url("https://postman-echo.com/post")
                                  .post(body)
                                  .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body.txt")
    return 0
}
```
### multipart 发送数据以及多上传文件

```cangjie
from okhttp import okhttp.*
from std import time.*
from std import fs.*

main() {
    let client: OkHttpClient= OkHttpClient.builder()
            .connectTimeout(Duration.millisecond(1000))
            .readTimeout(Duration.millisecond(1000))
            .writeTimeout(Duration.millisecond(1000))
            .build()
    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body1.txt", arr)
    File.writeTo("./body2.txt", arr)

    let body1 = RealRequestBody.create(MediaType.get("text/plain"),File("./body1.txt",OpenOption.Open(true,false)))
    let body2 = RealRequestBody.create(MediaType.get("text/plain"),File("./body2.txt",OpenOption.Open(true,false)))

    let mu = MultipartBody.builder().
    addFormDataPart("name", "huluwa").
    addFormDataPart("age", "18").
    addFormDataPart("file1", "body1.txt", body1).
    addFormDataPart("file2", "body2.txt", body2).
    build()

    let request = Request.builder()
                    .url("https://postman-echo.com/post")
                    .post(mu)
                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body1.txt")
    File.delete("./body2.txt")
}

```

### chunked分块传输请求
```cangjie
from okhttp import okhttp.*
from std import time.*
from std import io.*

main() {

    let client: OkHttpClient= OkHttpClient.builder().build()
    let request= okhttp.Request.builder()
                .url("https://postman-echo.com/post")
                .post(MyRequestBody())
                .build()
    let response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}
class MyRequestBody <:RequestBody {
    public func contentType(): Option<MediaType> {
        return MediaType.parse("application/json")
    }

    //声明的getContentLength -1，客户端拦截器默认添加"Transfer-Encoding", "chunked"头,使用ChunkedSink读取body
    public func getContentLength(): Int64 {
        return -1
    }

    public func writeTo(sink: Sink): Unit {
        //每次调用write都会产生一个传输块
        sink.write("hello".toUtf8Array())
        sink.write("world".toUtf8Array())
    }

    public func get(): InputStream {
        return ByteArrayStream()

    }
}

```
### 异步请求以及回调

```
from okhttp import okhttp.*
from std import time.*

main() {
     let client: OkHttpClient= OkHttpClient.builder()
                    .connectTimeout(Duration.millisecond(1000))
                    .readTimeout(Duration.millisecond(1000))
                    .writeTimeout(Duration.millisecond(1000))
                    .build()

    let request = Request.builder().url("https://www.baidu.com")
                    .header("User-Agent", "OkHttp-Example")
                    .build()

    for (i in 0..5) {
        let async = client.newCall(request)
        async.enqueue(MyCallbacks())
    }

    sleep(1000*1000*1000)
}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println("fail, ${e.message}")

    }

    public func onResponse(call: Call,  response: Response): Unit{
        println(response)
    }
}
```

### 拦截器使用

```cangjie
from okhttp import okhttp.*
from std import time.*


main (){
    let client: OkHttpClient= OkHttpClient.builder()
                .addNetworkInterceptor(MyInterceptor())//添加拦截器
                .connectTimeout(Duration.millisecond(1000))
                .readTimeout(Duration.millisecond(1000))
                .writeTimeout(Duration.millisecond(1000))
                .build()
    let request = Request.builder().url("https://postman-echo.com/get?foo1=bar1&foo2=bar2").build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}
//自定义拦截器打印route地址
class MyInterceptor<: Interceptor {
     public func intercept(chain: Chain): okhttp.Response {
        let conn = chain.getConnection().getOrThrow()
        println("route = ${conn.getRoute().getInetSocketAddress()}")
        return chain.proceed(chain.getRequest())
    }
}
```

### cookie管理

```cangjie
from okhttp import okhttp.*
from encoding import url.*
from std import time.*

main() {
    let url: URL = URL.parse("https://www.zhihu.com")
    let jar = getSimpleCookieJar()
    let client: OkHttpClient = OkHttpClient.builder().cookieJar(jar)
                            .connectTimeout(Duration.millisecond(1000))
                            .readTimeout(Duration.millisecond(1000))
                            .writeTimeout(Duration.millisecond(1000))
                            .build()
    let request = okhttp.Request.builder().url(url).build()
    let call = client.newCall(request)


    let response: okhttp.Response = call.execute()
    for (cookie in client.getCookieJar().loadForRequest(url)) {
        println(cookie.toString())
    }
    return 0

}
 
```
### 监听器使用

```cangjie
from okhttp import okhttp.*
from std import time.*
from encoding import url.*
from std import socket.*
from net import tls.*
from std import collection.*

main() {
    let url = URL.parse("https://postman-echo.com/get?foo1=bar1&foo2=bar2")

    let client: OkHttpClient= OkHttpClient.builder()
    .eventListener(MyEventListener())
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000))
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

    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException ): Unit {
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

```

### 使用http2协议

```cangjie
from okhttp import okhttp.*
from std import time.*
from encoding import url.*
from std import collection.*

main() {
    let url = URL.parse("https://www.taobao.com")

    let client: OkHttpClient= OkHttpClient.builder()
    .tlsConfig("./jjd.cer")//需要用户自己配置CA证书验证公钥,如果不配置CA证书将不进行服务端证书校验,将使用不安全的连接
    //H2_PRIOR_KNOWLEDGE 使用明文http2协议, 不支持https
    //.protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]))
    //使用apln协商协议,服务端响应支持的协议，list中前面的协议会被优先选择
    .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(),Protocol.get("HTTP/1.1").toString()]))
    .connectTimeout(Duration.millisecond(1000))
    .readTimeout(Duration.millisecond(1000))
    .writeTimeout(Duration.millisecond(1000))
    .build()

    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    return 0
}
```

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

主要写参与贡献的人以及个人主页链接

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。