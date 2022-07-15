# okhttp

## 描述
一个处理网络请求的轻量级框架

## 类描述

### Interface Builder

建造者模式，用于创建可链式调用配置项的配置类，最终创建出核心类

```cangjie
 func build(): T
```

###  class okhttpClinet

Call的工厂类，可用于发送 HTTP 请求并读取其响应，外观形式上等于http客户端，每个客户端都拥有自己的连接池和线程池。重用连接可减少延迟并节省内存。


```cangjie
//创建 OkHttpClient 的Builder
public static func builder(): OkHttpClientBuilder
//创建 Call 
public func newCall(request: Request): Call
//是否允许重定向
public func getFollowRedirects():Bool
//连接失败是否允许重试
public func getRetryOnConnectionFailure(): Bool
//获取客户端使用的连接池对象
public func getConnectionPool():  Option<ConnectionPool>
//获取客户端分发器
public func getDispatcher(): Dispatcher
//获取连接前拦截器
public func getInterceptors(): ArrayList<Interceptor>
//获取连接后拦截器
public func getNetworkInterceptors(): ArrayList<Interceptor>
//获取CookieJar
public func getCookieJar(): CookieJar
//获取连接超时时间
public func getConnectTimeout(): Option<Duration>
//获取读取连接超时时间
public func getReadTimeout(): Option<Duration>
//获取写连接超时时间
public func getWriteTimeout(): Option<Duration>
```

###  class okhttpClinetBuilder

用于创建okhttpClinet，用户通过链式调用配置其属性

```cangjie
//创建 OkHttpClient
public func build(): OkHttpClient
//配置分发器 
public func dispatcher(dispatcher: Dispatcher): OkHttpClientBuilder
//配置是否允许重定向
public func followRedirects(followRedirects: Bool): OkHttpClientBuilder
//配置连接失败是否允许重试
public func retryOnConnectionFailure(retryOnConnectionFailure: Bool): OkHttpClientBuilder
//配置客户端使用的连接池对象
public func connectionPool(connectionPool: Option<ConnectionPool>): OkHttpClientBuilder
//添加连接前拦截器
public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder
//添加连接后拦截器
public func addNetworkInterceptor(interceptor: Interceptor): OkHttpClientBuilder
//配置CookieJar
public func cookieJar(cookieJar: CookieJar): OkHttpClientBuilder
//配置连接超时时间
public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder
//配置读取连接超时时间
public func readTimeout(readTimeout: Duration): OkHttpClientBuilder
//配置写连接超时时间
public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder
```

### class RealCall<: Call

对已准备好执行的请求进行封装，准备执行

```cangjie
//获取请求
public func getRequest(): Request
//获取Transmitter
public func getTransmitter(): Transmitter
//进行同步请求
public func execute(): Response
//进行异步请求
public func enqueue(responseCallback: Callback):Unit
//取消请求
public func cancel(): Unit
//是否正在执行中
public func isExecuted(): Bool
//是否已取消
public func isCanceled(): Bool
//克隆新的Call
public func clone(): Call
```

### class Dispather
网络请求的执行器，可以定制发起异步请求的策略，以及同时运行异步请求的数量

```cangjie
//设置并发调用Call最大数
public func setMaxRequests(maxRequests: Int64): Unit
//获取并发调用Call最大数
public func getMaxRequests(): Int64
//设置同一个hostname的Call最大数
public func setMaxRequestsPerHost(maxRequestsPerHost: Int64): Unit
//获取同一个hostname的Call最大数
public func getMaxRequestsPerHost(): Int64
//取消执行所有的Call
public func cancelAll():Unit
//获取等待执行的Call数量
public func queuedCallsCount()
//获取正在运行中的Call数量
public func runningCallsCount(): Int64
```

###  class Chain

拦截器链

```
//获取Transmitter
public func getTransmitter(): Transmitter
//获取请求
public func getRequest(): Request
//获取Exchange
public func getExchange(): Exchange
//执行拦截器
public func proceed(request: Request,  transmitter: Transmitter, exchange: Option<Exchange>): Response
//执行拦截器
public func proceed(request: Request): Response
//获取连接超时时间
public func getConnectTimeout(): Option<Duration>
//获取读取连接超时时间
public func getReadTimeout(): Option<Duration>
//获取写连接超时时间
public func getWriteTimeout(): Option<Duration>
```

### Interface Interceptor

默认添加拦截器按顺序有

1.  RetryAndFollowUpInterceptor (负责 HTTP 请求的重定向功能，和重试机制)
2.  BridgeInterceptor(负责桥接功能，把用户所构建的请求转换为真正的 Request，将服务器所返回的响应转换为用户所能够使用的 Response)
3.  CacheInterceptor(主要负责了对缓存的读取以及更新)
4.  ConnectInterceptor(主要负责的是与服务器的连接的建立)
5.  CallServerInterceptor(它真正实现了对服务器连接的读取)

```
//对请求进行拦截处理
func intercept(chain: Chain): Response
```

### class Request

请求对象的封装

```
//获取URL
public func getUrl(): URL
//获取请求方法
public func getMethod(): String
//获取请求体
public func getBody(): Option<RequestBody>
//创建Builder
public static func builder(): RequestBuilder
//根据自身配置创建Builder
public func newBuilder(): RequestBuilder
//获取整个Header头
public func getHeaders(): Header
//获取Header中key对应的value,如果没有报错
public func getHeader(name: String): String
//获取Header中key对应的value,如果没有返回默认值
public func getHeader(name: String, defaultValue: String): String
//将其转换成仓颉http对应的Request对象
public func toHttpRequest(): http.Request
```

### class RequestBuilder
用于创建Request，用户通过链式调用配置其属性
```
//根据字符串配置URL
public func url(url: String): RequestBuilder
//根据URL配置
public func url(url: URL): RequestBuilder
//添加请求头key-value对
public func header( name: String, value: String): RequestBuilder
//配置请求方法
public func method(method: String): RequestBuilder
//配置请求体
public func body(requestBody: RequestBody): RequestBuilder
//创建Request
public func build(): Request
//移除请求头key对应value
public func removeHeader(name: String): Unit
//配置请求头
public func header(header: Header): ResponseBuilder
```

### class Response
http请求的响应对象

```
//创建Builder
public static func builder(): ResponseBuilder
//根据自身配置创建Builder
public func newBuilder(): ResponseBuilder
//获取Request
public func getRequest(): Request
//获取协议
public func getProtocol(): Protocol
//获取状态码
public func getCode(): Int64
//请求是否成功
public func isSuccess(): Bool
//获取整个Header头
public func getHeaders(): Header
//获取Header中key对应的value,如果没有报错
public func getHeader(name: String): String
//获取Header中key对应的value,如果没有返回默认值
public func getHeader(name: String, defaultValue: String): String
//获取响应体
public func getBody(): Option<ResponseBody>
//获取重定向的响应
public func getPrevResponse(): Option<Response>
//是否是重定向响应
public func isRedirect(): Bool
//关闭响应体
public func close()：Unit
//格式化输出
public func toString(): String
```

### class ResponseBuilder
用于创建Response，通过链式调用配置其属性
```
//创建Response
public func build(): Response
//配置请求
public func request(request: Request): ResponseBuilder
//配置协议
public func protocol(protocol: Protocol): ResponseBuilder
//配置状态码
public func code(code: Int64): ResponseBuilder
//配置message
public func message(message: String): ResponseBuilder
//重设响应头key-value对
public func header(name: String, value: String): ResponseBuilder
//添加响应头key-value对
public func addHeader(name: String, value: String): ResponseBuilder
//移除响应头key对应value
public func removeHeader( name: String): ResponseBuilder
//配置重定向响应
public func prevResponse(prevResponse: Option<Response>): ResponseBuilder
//配置响应体
public func body(body: ResponseBody): ResponseBuilder
//配置响应头
public func header(header: Header): ResponseBuilder

```


## 依赖三方库

    okio
    gzip
    http2
    webSocket            

##  展示示例

### 同步请求

```cangjie
from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example").build()
    let response: Response = client.newCall(request).execute()
    println(response.isSuccess())
}
```

运行结果

```cangjie
success
```

### 异步请求
```cangjie
from okhttp import okhttp.*
from std import time.*

main() {
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: Request = Request.builder().url("http://36.152.44.95/index.html")
    .header("User-Agent", "OkHttp-Example").build()
    client.newCall(request).enqueue(MyCallbacks())
    sleep(1000*1000*1000)
}

public class MyCallbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{
        println(e.getMessage())
    }
    public func onResponse(call: Call,  response: Response): Unit{
        println("success")
    }
}
```

运行结果

```cangjie
success
```