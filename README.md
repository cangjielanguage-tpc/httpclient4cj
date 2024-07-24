<div align="center">
<h1>Httpclient4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-85.0%25-brightgreen" style="display: inline-block;" /> 
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>介绍

Httpclient4cj 是一个高效的 HTTP 客户端, 代码参考: https://github.com/square/okhttp/tree/parent-3.14.9

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
│   └── design.md
└── src
```

- `doc`是库的设计文档、提案、库的使用文档、LLT 覆盖报告 ( 由于未支持服务端的对接,部分拦截器连接后处理逻辑暂时无法覆盖)
- `src`是库源码目录

## 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 编译执行

### 编译

编译描述和具体shell命令

1. linux x86_64 编译

   执行下面执行

   ```
   ./build_linux.sh
   ```

2. windows x64 编译

   执行下面执行

   ```
   build_windows.bat
   ```

3. ohos编译

   执行下面执行

   ```shell
   ./build_ohos.sh
   ```

## 示例

注意：以下示例请将`url`地址换成实际可用地址。

### 获取HttpClient对象并配置超时时间

```canjie
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
}
```

### 同步 GET 请求方法示例

```canjie
import httpclient4cj
import httpclient4cj.*
import std.time.*
import encoding.url.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response.getBody().getOrThrow().getString())
}
```
### 同步 Post 发送json字符串

```cangjie
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder()
        .url("http://127.0.0.1:50060")
        .post(RealRequestBody.create(MediaType.get("application/json; charset=utf-8"), "{\"id\": \"123\"}"))
        .build()
    let response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
}
```

### 同步 Post 发送文件内容

```cangjie
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.fs.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body.txt", arr)
    let file = File("./body.txt", OpenOption.Open(true, false))
    let body = RealRequestBody.create(MediaType.get("text/plain"), file)
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
        .url("http://127.0.0.1:50060")
        .post(body)
        .build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body.txt")
}
```
### multipart 发送数据以及多上传文件

```cangjie
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.fs.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    var arr: Array<Byte> = Array<Byte>(1024, {i => UInt8(i % 256)})
    File.writeTo("./body1.txt", arr)
    File.writeTo("./body2.txt", arr)
    let body1 = RealRequestBody.create(MediaType.get("text/plain"), File("./body1.txt", OpenOption.Open(true, false)))
    let body2 = RealRequestBody.create(MediaType.get("text/plain"), File("./body2.txt", OpenOption.Open(true, false)))
    let mu = MultipartBody.builder()
        .addFormDataPart("name", "huluwa")
        .addFormDataPart("age", "18")
        .addFormDataPart("file1", "body1.txt", body1)
        .addFormDataPart("file2", "body2.txt", body2)
        .build()
    let request = Request.builder().url("http://127.0.0.1:50060").post(mu).build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    File.delete("./body1.txt")
    File.delete("./body2.txt")
}
```

### chunked分块传输请求
```cangjie
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.io.*

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
```
### 异步请求以及回调

```
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder()
        .url("http://127.0.0.1:50060")
        .header("User-Agent", "Httpclient4cj-Example")
        .build()
    for (i in 0..5) {
        let async = client.newCall(request)
        async.enqueue(MyCallbacks())
    }
    sleep(Duration.second)
}
public class MyCallbacks <: Callback {
    public func onFailure(call: Call, e: Exception): Unit {
        println("fail, ${e.message}")
    }
    public func onResponse(call: Call, response: Response): Unit {
        println(response)
    }
}
```

### 拦截器使用

```cangjie
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .addNetworkInterceptor(MyInterceptor())
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url("http://127.0.0.1:50060").build()
    let response: Response = client.newCall(request).execute()
    println(response.getBody().getOrThrow().getString())
    return 0
}
// 自定义拦截器打印route地址
class MyInterceptor <: Interceptor {
    public func intercept(chain: Chain): httpclient4cj.Response {
        let conn = chain.getConnection().getOrThrow()
        println("route = ${conn.getRoute().getInetSocketAddress()}")
        return chain.proceed(chain.getRequest())
    }
}
```

### cookie管理

```cangjie
import encoding.url.*
import httpclient4cj
import httpclient4cj.*
import std.time.*

main() {
    let url: URL = URL.parse("http://127.0.0.1:50060")
    let jar = getSimpleCookieJar()
    let client: HttpClient = HttpClient.builder()
        .cookieJar(jar)
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = httpclient4cj.Request.builder().url(url).build()
    let call = client.newCall(request)
    let response: httpclient4cj.Response = call.execute()
    for (cookie in client.getCookieJar().loadForRequest(url)) {
        println(cookie.toSetCookieString())
    }
    return 0
}
```
### 监听器使用

```cangjie
import encoding.url.*
import httpclient4cj
import httpclient4cj.*
import net.tls.*
import std.collection.*
import std.socket.*
import std.time.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    let client: HttpClient = HttpClient.builder()
        .eventListener(MyEventListener())
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
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
    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException): Unit {
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
import encoding.url.*
import httpclient4cj
import httpclient4cj.*
import net.tls.*
import std.collection.*
import std.time.*

main() {
    let url = URL.parse("http://127.0.0.1:50060")
    // 需要用户自己配置CA证书验证公钥,如果不配置CA证书将不进行服务端证书校验,将使用不安全的连接
    // H2_PRIOR_KNOWLEDGE 使用明文http2协议, 不支持https
    // .protocols(ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]))
    // 使用apln协商协议,服务端响应支持的协议，list中前面的协议会被优先选择
    let client: HttpClient = HttpClient.builder()
        .tlsConfig(TlsClientConfig())
        .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(), Protocol.get("HTTP/1.1").toString()]))
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
    let request = Request.builder().url(url).build()
    let call = client.newCall(request)
    let response = call.execute()
    println(response)
    return 0
}
```

## 开源协议

本项目基于 [Apache-2.0 license](LICENSE) , 请自由享受和参与开源

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

主要写参与贡献的人以及个人主页链接

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。