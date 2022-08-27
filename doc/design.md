# okhttp

## 描述
一个处理网络请求的轻量级框架

## 类描述

### Interface Builder

建造者模式，用于创建可链式调用配置项的配置类，最终创建出核心类

```cangjie
 func build(): T
```

###  class okhttpClient

Call的工厂类，可用于发送 HTTP 请求并读取其响应，外观形式上等同于http客户端，每个客户端都拥有自己的连接池和线程池。重用连接可减少延迟并节省内存。


```cangjie
public class OkHttpClient {
    /*
     * 创建 OkHttpClient 的Builder 
     *
     * 返回值 OkHttpClientBuilder - 返回用于创建自身的builder
     */
    public static func builder(): OkHttpClientBuilder
    /*
     * 配置个性化的请求分发器 
     *
     * 参数 request http 的请求对象
     * 返回值 Call - 包装后预备执行新的请求对象
     */
    public func newCall(request: Request): Call
    /*
     * 获取是否允许重定向
     *
     * 返回值 Bool - 请求是否允许重定向
     */
    public func getFollowRedirects():Bool
    /*
     * 连接失败是否允许重试
     *
     * 返回值 Bool - 请求连接失败是否允许重试
     */
    public func getRetryOnConnectionFailure(): Bool
    /*
     * 获取客户端使用的连接池对象
     *
     * 返回值 Option<ConnectionPool> - 客户端使用的连接池对象
     */
    public func getConnectionPool():  Option<ConnectionPool>
    /*
     * 获取客户端分发器
     *
     * 返回值 Dispatcher - 客户端使用连接分发器对象
     */
    public func getDispatcher(): Dispatcher
    /*
     * 获取自定义连接前处理拦截器
     *
     * 返回值 ArrayList<Interceptor> - 自定义连接前拦截器的集合
     */
    public func getInterceptors(): ArrayList<Interceptor>
    /*
     * 获取自定义连接后处理拦截器
     *
     * 返回值 ArrayList<Interceptor> - 自定义连接后处理拦截器的集合
     */
    public func getNetworkInterceptors(): ArrayList<Interceptor>
    /* 获取CookieJar
     *
     * 返回值 CookieJar - CookieJar对象
     */
    public func getCookieJar(): CookieJar
    /* 获取连接超时时间
     *
     * 返回值 Option<Duration> - 连接超时时间对象
     */
    public func getConnectTimeout(): Option<Duration>
    /* 获取读取连接超时时间
     *
     * 返回值 Option<Duration> - 读取连接超时时间
     */
    public func getReadTimeout(): Option<Duration>
    /* 获取写连接超时时间
     *
     * 返回值 Option<Duration> - 写连接超时时间
     */
    public func getWriteTimeout(): Option<Duration>
    /* 获取使用的http协议
     *
     * 返回值 ArrayList<String> - 使用的http协议
     */
    public func getProtocols(): ArrayList<String>
}
```

###  class okhttpClientBuilder

用于创建okhttpClient，用户通过链式调用配置其属性

```cangjie
public class OkHttpClientBuilder <: Builder<OkHttpClient> {
    /*
     * 通过配置项创建出核心类 OkHttpClient
     *
     * 返回值 OkHttpClient - 核心类 OkHttpClient 对象
     */
    public func build(): OkHttpClient
    /*
     * 配置个性化的请求分发器 
     *
     * 参数 dispatcher 用户自定义的Dispatcher对象
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func dispatcher(dispatcher: Dispatcher): OkHttpClientBuilder
    /*
     * 配置是否允许重定向, 默认为true
     *
     * 参数 followRedirects Bool值是否允许重定向
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func followRedirects(followRedirects: Bool): OkHttpClientBuilder
    /*
     * 配置连接失败是否允许重试,默认为true
     *
     * 参数 followRedirects Bool值是否允许重试
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func retryOnConnectionFailure(retryOnConnectionFailure: Bool): OkHttpClientBuilder
    
    /*
     * 配置客户端使用个性化的连接池对象
     *
     * 参数 connectionPool 如果默认或 None 的话，使用默认最大空闲数为5，最大空闲时间为5分钟的连接池
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func connectionPool(connectionPool: Option<ConnectionPool>): OkHttpClientBuilder
    /*
     * 添加用户自定义的连接前处理的拦截器
     *
     * 参数 interceptor 拦截器对象
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder
    /*
     * 添加用户自定义的连接后处理的拦截器
     *
     * 参数 interceptor 拦截器对象
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     */
    public func addNetworkInterceptor(interceptor: Interceptor): OkHttpClientBuilder
    /*
     * 配置连接超时时间
     *
     * 参数 connectTimeout 连接超时时间对象
     * 如果连接超时, 如果followRedirects配置为 false 抛出异常
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     * 
     */
    public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder
    /*
     * 配置读取连接超时时间
     *
     * 参数 readTimeout 连接超时时间对象
     * 如果读取连接超时, 如果followRedirects配置为 false 抛出异常
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     * 
     */
    public func readTimeout(readTimeout: Duration): OkHttpClientBuilder
    /*
     * 配置读取连接超时时间
     *
     * 参数 writeTimeout 连接超时时间对象
     * 如果写连接超时, 如果followRedirects配置为 false 抛出异常
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     * 
     */
    public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder
    
    /*
     * 配置读取连接超时时间
     *
     * 参数 protocols 使用协议的集合,
     * 目前版本只支持 http/1.1, 强制使用http1.1
     * 以及 h2_prior_knowledge, 强制使用http2
     * 返回值 OkHttpClientBuilder - 链式调用返回自身
     * 
     */
    public func protocols(protocols: ArrayList<String>): OkHttpClientBuilder
}
```

### interface Call

对已准备好执行的请求进行封装，准备执行

```cangjie
public interface Call {
    /* 获取封装的请求对象
     *
     * 返回值 Request - 封装的请求对象
     */
    public func getRequest(): Request
    /* 同步进行请求
     *
     * 返回值 Response - 请求的响应对象
     */
    public func execute(): Response
    /* 异步进行请求
     *
     * 参数 responseCallback - 对请求响应的回调函数
     */
    public func enqueue(responseCallback: Callback):Unit
    /* 取消请求，对于已经完成的请求无法取消
     *
     */
    public func cancel(): Unit
    /* 请求是否正在执行中或者已经执行完成
     * 注意已经请求完成过一次的 call 无法再次执行
     */
    public func isExecuted(): Bool
    /* 请求是否已取消
     * 
     */
    public func isCanceled(): Bool
    /* 克隆新的Call对象
     * 
     */
    public func clone(): Call
}
```

### class Dispatcher
网络请求的执行器，可以定制发起异步请求的策略，以及同时运行异步请求的数量

```cangjie
public class Dispatcher {
    /* 设置并发调用Call最大数
     * 
     * 参数 maxRequests - 并发最大值
     */
    public func setMaxRequests(maxRequests: Int64): Unit
    /* 获取并发调用Call最大数
     * 
     * 返回值 maxRequests - 并发最大值
     */
    public func getMaxRequests(): Int64
    /* 设置分发器空闲时的回调函数
     * 
     * 参数 idleCallback - 回调函数
     */
    public func setIdleCallback(idleCallback: Option<()-> Unit>): Unit
    /* 设置同一个hostname的Call最大并发数
     * 注意这里是对URL解析后的hostname而不是dns解析后的ip
     * 如果不同域名解析成同一个ip这里无法限制
     *
     * 参数 maxRequestsPerHost - 最大并发数
     */
    public func setMaxRequestsPerHost(maxRequestsPerHost: Int64): Unit
    /* 获取同一个hostname的Call最大并发数
     *
     * 返回值 Int64 - 最大并发数
     */
    public func getMaxRequestsPerHost(): Int64
    /* 取消执行所有运行中和预备运行的Call对象
     *
     */
    public func cancelAll():Unit
    /* 获取等待运行的Call数量
     *
     * 参数 Int64 - 等待运行的Call数量
     */
    public func queuedCallsCount(): Int64
    /* 获取正在运行中的Call数量
     *
     * 参数 Int64 - 正在运行中的Call数量
     */
    public func runningCallsCount(): Int64
}
```

###  class Chain

拦截器链

```
public class Chain {
    /* 获取Transmitter对象
     *
     * 返回值 Transmitter - Transmitter对象
     */
    public func getTransmitter(): Transmitter
    /* 获取请求对象
     *
     * 返回值 Request - 请求对象
     */
    public func getRequest(): Request
    /* 获取Exchange对象
     *
     * 返回值 Request - Exchange对象
     */
    public func getExchange(): Exchange
    /*
     * 执行拦截器
     *
     * 参数 request 请求对象
     * 返回值 Response - 响应对象
     * 
     */
    public func proceed(request: Request): Response
    /*
     * 执行拦截器重载
     *
     * 参数 request 请求对象
     * 参数 transmitter 应用层和网络层抽象对象
     * 参数 exchange, 对http请求和响应的解析对象
     * 返回值 Response - 响应对象
     * 
     */
    public func proceed(request: Request,  transmitter: Transmitter, exchange: Option<Exchange>): Response
    /*
     * 获取Call对象
     *
     * 返回值 Call - Call实例
     * 
     */
    public func getCall(): Call
    /*
     * 获取连接对象
     *
     * 返回值 Option<Connection> - 连接对象
     * 
     */
    public func getConnection(): Option<Connection>
}
```

### Interface Interceptor

默认添加拦截器按顺序有

1.  RetryAndFollowUpInterceptor (负责 HTTP 请求的重定向功能，和重试机制)
2.  BridgeInterceptor(负责桥接功能，把用户所构建的请求转换为真正的 Request，将服务器所返回的响应转换为用户所能够使用的 Response)
3.  CacheInterceptor(主要负责了对缓存的读取以及更新, 目前未开发)
4.  ConnectInterceptor(主要负责的是与服务器的连接的建立)
5.  CallServerInterceptor(它真正实现了对服务器连接的读取)

```
//对请求进行拦截处理
func intercept(chain: Chain): Response
```

### class Request

请求对象

```
public class Request {
    /*
     * 获取URL对象
     *
     * 返回值 URL - URL实例
     * 
     */
    public func getUrl(): URL
    /*
     * 获取请求方法
     *
     * 返回值 String - 请求方法字符串
     * 
     */
    public func getMethod(): String
    /*
     * 获取请求体
     *
     * 返回值 Option<RequestBody> - 请求体
     * 
     */
    public func getBody(): Option<RequestBody>
    /*
     * 创建Builder
     *
     * 返回值 RequestBuilder - 构建器
     * 
     */
    public static func builder(): RequestBuilder
    /*
     * 根据自身配置创建Builder
     *
     * 返回值 RequestBuilder - 构建器
     * 
     */
    public func newBuilder(): RequestBuilder
    /*
     * 获取整个Header头对象
     *
     * 返回值 Header - 请求头对象
     * 
     */
    public func getHeaders(): Header
    /*
     * 获取Header中key对应的 Option<String>
     *
     * 参数 name key 值
     *
     * 返回值 Option<String> - value值
     * 
     */
    public func getHeader(name: String): Option<String>
    /*
     * 获取Header中key对应的value,如果没有返回默认值
     * 
     * 参数 name key值
     * 参数 defaultValue 默认值
     *
     * 返回值 String - value值
     * 
     */
    public func getHeader(name: String, defaultValue: String): String
    /*
     * 转换成仓颉http库对应的Request对象
     *
     * 返回值 http.Request - 仓颉http库对应的Request对象
     * 
     */
    public func toHttpRequest(): http.Request
    /*
     * 获取请求中缓存控制对象
     *
     * 返回值 Option<CacheControl> - 缓存控制对象
     * 
     */
    public func getCacheControl(): Option<CacheControl>
} 
```

### class RequestBuilder
用于创建Request，用户通过链式调用配置其属性
```
public class RequestBuilder <: Builder<Request> {
    /*
     * 根据字符串配置URL
     *
     * 参数 url URL字符串
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     */
    public func url(url: String): RequestBuilder
    /*
     * 重载根据URL配置
     *
     * 参数 url URL对象
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     */
    public func url(url: URL): RequestBuilder
    /*
     * 添加请求头key-value键值对
     *
     * 参数 name key值
     * 参数 value value值
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func header( name: String, value: String): RequestBuilder
    /*
     * 配置请求方法
     *
     * 参数 method 请求方法字符串
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func method(method: String): RequestBuilder
    /*
     * 配置请求体
     *
     * 参数 requestBody 请求体
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func body(requestBody: RequestBody): RequestBuilder
    /*
     * 创建Request
     *
     * 返回值 Request - 请求对象
     * 
     *
    public func build(): Request
    /*
     * 移除请求头key对应的value
     * 
     * 参数 name key值
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func removeHeader(name: String): RequestBuilder
    /*
     * 配置请求头
     * 
     * 参数 header 请求头实例
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func header(header: Header): ResponseBuilder
    /*
     * 配置请求中缓存控制头
     * 
     * 参数 cacheControl 缓存控制实例
     *
     * 返回值 RequestBuilder - 链式调用返回自身
     * 
     *
    public func cacheControl(cacheControl: CacheControl): RequestBuilder
}
```

### class RequestBody
请求体对象
```cangjie
public class RequestBody {
    /*
     * 获取请求体的contentType
     *
     *
     * 返回值 String - contentType字符串
     *
     *
    public func contentType(): String
    /*
     * 获取请求体的长度
     *
     *
     * 返回值 Int64 - 长度
     *
     *
    public func contentLength(): Int64 
    /*
     * 获取请求体的输出流
     *
     *
     * 返回值 InputStream - 输出流
     *
     *
    public func get(): InputStream 
}
```

### class Response

请求的响应

```cangjie
public class Response {
    /*
     * 创建 Response 的 Builder
     *
     * 返回值 ResponseBuilder - Response的配置器
     *
    public static func builder(): ResponseBuilder
    /*
     * 根据自身配置创建 Builder
     *
     * 返回值 ResponseBuilder - Response的配置器
     *
    public func newBuilder(): ResponseBuilder
    /*
     * 获取对应的 Request 对象
     *
     * 返回值 Request - 请求对象
     *
    public func getRequest(): Request
    /*
     * 获取协议
     *
     * 返回值 Protocol - 协议对象
     *
    public func getProtocol(): Protocol
    /*
     * 获取获取状态码
     *
     * 返回值 Int64 - 状态码
     *
    public func getCode(): Int64
    /*
     * 请求是否成功
     *
     * 返回值 Bool - 是否成功
     *
    public func isSuccess(): Bool
    /*
     * 获取整个响应头
     *
     * 返回值 Header -响应头
     *
    public func getHeaders(): Header
    /*
     * 获取Header中key对应的value
     *
     * 参数 name key值
     *
     * 返回值 Option<String> - value值
     *
    public func getHeader(name: String): Option<String>
    /*
     * 获取Header中key对应的value,如果没有返回默认值
     *
     * 参数 name key值
     * 参数 defaultValue 默认值
     *
     * 返回值 String - value值
     *
    public func getHeader(name: String, defaultValue: String): String
    /*
     * 获取响应体
     *
     * 返回值 Option<ResponseBody> - 响应体
     *
    public func getBody(): Option<ResponseBody>
    /*
     * 获取重定向的前置响应对象
     *
     * 返回值 Option<ResponseBody> - 响应对象
     *
    public func getPrevResponse(): Option<Response>
    /*
     * 是否是重定向响应
     *
     * 返回值 Bool - 是否是重定向响应
     *
    public func isRedirect(): Bool
    /*
     * 关闭响应体资源
     *
     *
    public func close()：Unit
    /*
     * 格式化输出
     *
     * 返回值 String - 格式化输出字符串
     *
    public func toString(): String
    /*
     * 获取缓存控制对象
     *
     * 返回值 Option<CacheControl> - 缓存控制对象
     *
    public func getCacheControl(): Option<CacheControl>
}
```
### class ResponseBody

响应体

```cangjie
public class ResponseBody {
    /*
     * 参数 contentType 响应体类型
     * 参数 contentLength 响应体长度
     * 参数 响应体字节流对象
     */
    public init(contentType: String, contentLength: Int64, source: ByteArrayStream)
    /*
     * 获取响应体字节流
     *
     * 返回值 ByteArrayStream - 字节流
     */
    public func getSource(): ByteArrayStream
    /*
     * 获取响应体长度
     *
     * 返回值 Int64 - 长度
     */
    public func getContentLength(): Int64
    /*
     * 获取响应体类型
     *
     * 返回值 String - 响应体类型的字符串
     */
    public func getContentType(): String
}
```

### class ResponseBuilder
用于创建Response，通过链式调用配置其属性

```
public open class ResponseBuilder <: Builder<Response> {
    /*
     * 通过配置项创建出核心类 Response
     *
     * 返回值 Response - 核心类 Response 对象
     */
    public func build(): Response
    /*
     * 配置原请求对象
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func request(request: Request): ResponseBuilder
    /*
     * 配置使用http协议
     *
     * 参数值 protocol 协议字符串
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func protocol(protocol: Protocol): ResponseBuilder
    /*
     * 配置状态码
     *
     * 参数值 code 状态码
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func code(code: Int64): ResponseBuilder
    /*
     * 配置状态信息
     *
     * 参数值 message 状态信息
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func message(message: String): ResponseBuilder
    
    /*
     * 重设响应头key-value键值对
     *
     * 参数值 name key值
     * 参数值 value value值
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func header(name: String, value: String): ResponseBuilder
    /*
     * 添加响应头key-value键值对
     *
     * 参数值 name key值
     * 参数值 value value值
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func addHeader(name: String, value: String): ResponseBuilder
    /*
     * 移除响应头key-value键值对
     *
     * 参数值 name key值
     * 参数值 value value值
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func removeHeader(name: String): ResponseBuilder
    /*
     * 配置重定向的前置响应对象
     * 注意，如果参数不为None的话，如果响应对象的 body 不为 None，抛异常
     *
     * 参数值 prevResponse key值
     * 参数值 value value值
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func prevResponse(prevResponse: Option<Response>): ResponseBuilder
    /*
     * 配置响应体
     *
     * 参数值 body 响应体
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func body(body: ResponseBody): ResponseBuilder
    /*
     * 配置响应头
     *
     * 参数值 body 响应头
     *
     * 返回值 ResponseBuilder - 链式调用返回自身
     */
    public func header(header: Header): ResponseBuilder
}
```

### Route
连接服务器的路由

```cangjie
public class Route <: Hashable & Equatable<Route>{
    /*
     * 参数 address  包含服务器地址和连接协议的对象
     * 参数 inetSocketAddress 标准库SocketAddress类型表示socket地址
     */
    public init (address: Address, inetSocketAddress: SocketAddress)
    /*
     * 获取 Address 对象
     *
     * 返回值 Address - Address对象
     */
    public func getAddress(): Address
}
```

### Address
包含服务器地址和连接协议的对象

```cangjie
public class Address <: Hashable & Equatable<Address>{
    /*
     * 参数 url  服务器URL
     * 参数 protocols 请求协议
     */
    public init (url: URL, protocols: ArrayList<String>) {
    /*
     * 获取 URL 对象
     *
     * 返回值 URL - URL对象
     */
    public func getUrl(): URL {
        return url
    }

    /**
     * 获取协议
     *
     * 返回值 ArrayList<String> - 协议
     */
    public func getProtocols(): ArrayList<String>{
}
```

### protocol
```cangjie
public enum Protocol {

     HTTP_1_1 | H2_PRIOR_KNOWLEDGE
    /*
     * 通过字符串获取协议对象
     *
     * 参数 protocol 协议字符串
     *
     * 返回值 Protocol<String> - 协议对象
     */
     public static func get(protocol: String): Protocol
     
    /*
     * 格式化输出
     *
     *
     * 返回值 String - 协议字符串
     */
    
     public func toString(): String 
}
```
### Transmitter

```cangjie
public class Transmitter {
    /*
     * 参数 client 客户端配置对象
     * 参数 call 请求的封装
     *
     */
    public init (client: OkHttpClient, call: Call) {
    /*
     * 关闭连接
     *
     *
    public func cancel(): Unit 
    /*
     * 是否已关闭
     * 
     * 返回值 Bool - 是否已关闭
     *
    public func isCanceled(): Bool 
    
    
    /*
     * 进行准备连接前必要的初始化
     * 如果已经进行过一次连接，判断是否可以可以复用 
     *
     * 参数 request 请求对象
     *
    public func prepareToConnect(request: Request): Unit
    
    /* 是否已经建立连接
     *
     *
     * 返回值 Bool 是否已经建立连接
     *
    public func hasConnection()
    
    
    /* 是否已经建立传输通道
     *
     *
     * 返回值 Bool 是否已经建立传输通道
     *
    public func hasExchange(): Bool 
    /* 由于异常关闭传输通道
     *
     *
    public func exchangeDoneDueToException(): Unit
    /* 是否可以重试
     *
     * 返回值 Bool - 是否可以重试
     *
    public func canRetry(): Bool 
}

```
### Connection

```cangjie
public class Connection {
    /*
     * 参数 client 连接池对象
     * 参数 call 路由对象
     *
     */
    public init(connectionPool: ConnectionPool, route: Route)
    /*
     * 获取协议
     *
     * 返回值 Protocol - 协议对象
     *
    public func getProtocol(): Protocol
    /*
     * 获取该连接关联的所有Transmitter实例
     *
     * 返回值 ArrayList<Transmitter> - Transmitter实例集合
     *
    public func getTransmitters(): ArrayList<Transmitter>
    /*
     * 标记该连接上不可再传输
     *
     *
    public func noExchanges(): Unit 
    /*
     * 获取socket
     *
     * 返回值 Option<Socket> - socket连接
     *
    public func getSocket(): Option<Socket>
    /*
     * 获取路由对象
     *
     * 返回值 Route - 路由对象
     *
    public func getRoute(): Route
    /*
     * 连接是否健康可用
     *
     * 返回值 Bool - 是否健康可用
     *
    public func isHealthy(): Bool {
    /*
     * 连接是否支持多路复用
     *
     * 返回值 Bool - 是否支持多路复用
     *
    public func isMultiplexed(): Bool
    /*
     * 开始连接
     *
     * 参数 connectTimeout socket连接超时时间
     * 参数 connectionRetryEnabled 连接失败是否进行重试
     *
    public func connect(connectTimeout: Option<Duration>, connectionRetryEnabled: Bool)
    /*
     * 关闭socket
     *
     *
    public func cancel(): Unit
}
```

### ConnectionPool

```cangjie
public class ConnectionPool {
    /*
     * 参数 maxIdleConnections 最大空闲连接数, 默认为5
     * 参数 keepAliveDurationNs 连接最大空闲保持存活时间 默认为5分钟  
     *
     */
    public init(maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute(5))
    /*
     * 获取当前空闲连接数
     *   
     * 返回值 Int64 - 当前空闲连接数
     */
    public func idleConnectionCount(): Int64 
    /*
     * 移除并关闭所有空闲连接
     *   
     */
    public func evictAll(): Unit
    /*
     * 记录连接失败的路由
     * 
     * 参数 failedRoute 失败路由对象  
     */
    public func connectFailed(failedRoute: Route): Unit {
}
```


## 依赖三方库
    http2 

##  展示示例

### 同步请求

```cangjie
from okhttp import okhttp.*

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