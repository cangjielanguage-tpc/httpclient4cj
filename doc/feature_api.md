# okhttp

## 功能

### api接口

#### Interface Builder

建造者模式，用于创建可链式调用配置项的配置类，最终创建出核心类。

```
/*
 * 创建出核心类。
 * @return T
 */
public func build(): T


```

#### class OkhttpClient

Call的工厂类，可用于发送 HTTP 请求并读取其响应，外观形式上等同于http客户端，每个客户端都拥有自己的连接池和线程池。重用连接可减少延迟并节省内存。

```
/*
 * 增强请求对象
 * @param request: Request
 * @return Call
 */
public func newCall(request: Request): Call
/*
 * 请求是否允许重定向
 * @return Bool
 */
public func getFollowRedirects(): Bool
/*
 * 连接失败是否允许重试
 * @return Bool
 */
public func getRetryOnConnectionFailure(): Bool
/*
 * 获取客户端使用的连接池对象
 * @return Option<ConnectionPool>
 */
public func getConnectionPool(): Option<ConnectionPool>
/*
 * 获取客户端分发器
 * @return Dispatcher
 */
public func getDispatcher(): Dispatcher
/*
 * 获取自定义连接前处理拦截器
 * @return ArrayList<Interceptor>
 */
public func getInterceptors(): ArrayList<Interceptor>
/*
 * 获取自定义连接后处理拦截器
 * @return ArrayList<Interceptor>
 */
public func getNetworkInterceptors(): ArrayList<Interceptor>
/*
 * 获取CookieJar
 * @return CookieJar
 */
public func getCookieJar(): CookieJar
/*
 * 获取连接超时时间
 * @return Option<Duration>
 */
public func getConnectTimeout(): Option<Duration>
/*
 * 获取读取连接超时时间
 * @return Option<Duration>
 */
public func getReadTimeout(): Option<Duration>
/*
 * 获取写连接超时时间
 * @return Option<Duration>
 */
public func getWriteTimeout(): Option<Duration>
/*
 * 获取使用的http协议
 * @return ArrayList<String>
 */
public func getProtocols(): ArrayList<String>
/*
 * 获取tls的CA证书
 * @return Option<TlsClientConfig>
 */
public func getTlsConfig(): Option<TlsClientConfig>
/*
 * 获取鉴权配置
 * @return (Option<Route>, Response)-> Option<Request>
 */
public func getAuthenticator(): (Option<Route>, Response)-> Option<Request>
/*
 * 获取是否允许跨协议进行重定向
 * @return Bool
 */
public func getFollowSslRedirects(): Bool
/*
 * 获取事件监听器
 * @return EventListener
 */
public func getEventListener(): EventListener
/*
 * 获取缓存对象
 * @return Option<Cache>
 */
public func getCache(): Option<Cache>

/*
 * 创建 OkHttpClient 的 Builder
 * @return OkHttpClientBuilder
 */
public static func builder(): OkHttpClientBuilder


```

#### class okhttpClientBuilder

用于创建okhttpClient，用户通过链式调用配置其属性

```
/*
 * 通过配置项创建出核心类 OkHttpClient
 * @return OkHttpClient
 */
public func build(): OkHttpClient
/*
 * 配置个性化的请求分发器
 * @param dispatcher: Dispatcher
 * @return OkHttpClientBuilder
 */
public func dispatcher(dispatcher: Dispatcher): OkHttpClientBuilder
/*
 * 配置是否允许重定向, 默认为true
 * @param followRedirects: Bool
 * @return OkHttpClientBuilder
 */
public func followRedirects(followRedirects: Bool): OkHttpClientBuilder
/*
 * 配置连接失败是否允许重试,默认为true
 * @param retryOnConnectionFailure: Bool
 * @return OkHttpClientBuilder
 */
public func retryOnConnectionFailure(retryOnConnectionFailure: Bool): OkHttpClientBuilder
/*
 * 配置客户端使用个性化的连接池对象 ，默认最大空闲数为5，最大空闲时间为5分钟
 * @param connectionPool: Option<ConnectionPool>
 * @return OkHttpClientBuilder
 */
public func connectionPool(connectionPool: Option<ConnectionPool>): OkHttpClientBuilder
/*
 * 添加用户自定义的连接前处理的拦截器
 * @param interceptor: Interceptor
 * @return OkHttpClientBuilder
 */
public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder
/*
 * 添加用户自定义的连接后处理的拦截器
 * @param interceptor: Interceptor
 * @return OkHttpClientBuilder
 */
public func addNetworkInterceptor(interceptor: Interceptor): OkHttpClientBuilder
/*
 * 配置连接超时时间
 * @param connectTimeout: Duration
 * @return OkHttpClientBuilder
 */
public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder
/*
 * 配置读取连接超时时间
 * @param readTimeout: Duration
 * @return OkHttpClientBuilder
 */
public func readTimeout(readTimeout: Duration): OkHttpClientBuilder
/*
 * 配置cookieJar，默认使用cookieJar不保存cookie，也无法获取cookie，可以使用全局函数getSimpleCookieJar获取轻量的cookieJar对象
 * @param cookieJar: CookieJar
 * @return OkHttpClientBuilder
 */
public func cookieJar(cookieJar: CookieJar): OkHttpClientBuilder
/*
 * 配置读取连接超时时间
 * @param writeTimeout: Duration
 * @return OkHttpClientBuilder
 */
public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder
/*
 * 参数 protocols 使用协议的集合, 支持 http/1.1, http2 以及 h2_prior_knowledge
 * @param protocols: ArrayList<String>
 * @return OkHttpClientBuilder
 * @throw IllegalArgumentException  http/1.1和h2_prior_knowledge必须且之只能存在一个，h2_prior_knowledge不能使用其他协议
 * 不能使用http1.0 不能为空
 */
public func protocols(protocols: ArrayList<String>): OkHttpClientBuilder
/*
 * 开启tls, 配置tls 的 CA证书路径
 * @param path: String
 * @return OkHttpClientBuilder
 */
public func tlsConfig(path: String): OkHttpClientBuilder
/*
 * 开启鉴权配置 (如果 code 返回 401 则需要鉴权配置), 如果lambda返回None则不再进行重试, 否则进行鉴权配置后重试请求
 * @param authenticator: (Option<Route>
 * @param Response) -> Option<Request>
 * @return OkHttpClientBuilder
 */
public func authenticator(authenticator: (Option<Route>, Response) -> Option<Request>): OkHttpClientBuilder
/*
 * 配置是否允许跨协议进行重定向
 * @param followSslRedirects: Bool
 * @return OkHttpClientBuilder
 */
public func followSslRedirects(followSslRedirects: Bool): OkHttpClientBuilder
/*
 * 配置自定义事件监听器
 * @param listener: EventListener
 * @return OkHttpClientBuilder
 */
public func eventListener(listener: EventListener): OkHttpClientBuilder
/*
 * 配置使用缓存，默认不开启缓存功能
 * @param cache: Option<Cache>
 * @return OkHttpClientBuilder
 */
public func cache(cache: Option<Cache>): OkHttpClientBuilder

```

#### interface Call

对已准备好执行的请求进行增强行后再执行，已经请求完成过一次的 call 无法再次执行

```
/*
 * 获取封装的请求对象
 * @return Request
 */
public func getRequest(): Request
/*
 * 同步进行请求
 * @return Response
 * @throw HttpException
 * @throw IllegalStateException
 * @throw IllegalArgumentException
 */
public func execute(): Response
/*
 * 异步进行请求
 * @param responseCallback: Callback 回调函数
 * @throw HttpException - 已经处理过请求
 */
public func enqueue(responseCallback: Callback): Unit
/*
 * 取消请求，注意对于已经完成的请求无法取消
 */
public func cancel(): Unit
/*
 * 请求是否正在执行中或者已经执行完成
 * @return Bool
 */
public func isExecuted(): Bool
/*
 * 请求是否已取消
 * @return Bool
 */
public func isCanceled(): Bool
/*
 * 克隆新的Call对象
 * @return Call
 */
public func clone(): Call

```

#### interface CallBack

异步请求的回调处理接口

```
/*
 * 异常回调处理
 * @param call: Call
 * @param e: Exception
 */
public func onFailure(call: Call,  e: Exception): Unit
/*
 * 正常回调处理
 * @param call: Call
 * @param response: Response
 */
public func onResponse(call: Call,  response: Response): Unit

```

#### class Dispatcher

网络请求的执行器，可以定制发起异步请求的策略，以及同时运行异步请求的数量


```
/*
 * 无参构造
 */
public init() 
/*
 * 设置并发调用Call最大数
 * @param maxRequests: Int64
 * @throw IllegalArgumentException maxRequests <1
 */
public func setMaxRequests(maxRequests: Int64): Unit
/*
 * 获取并发调用Call最大数
 * @return Int64
 */
public func getMaxRequests(): Int64
/*
 * 设置分发器空闲时的回调函数
 * @param idleCallback: Option<()-> Unit>
 */
public func setIdleCallback(idleCallback: Option<()-> Unit>): Unit
/*
 * 设置同一个hostname的Call最大并发数， 注意这里是对URL解析后的hostname而不是dns解析后的ip 如果不同域名解析成同一个ip这里无法限制
 * @param maxRequestsPerHost: Int64
 * @throw IllegalArgumentException maxRequestsPerHost <1
 */
public func setMaxRequestsPerHost(maxRequestsPerHost: Int64): Unit
/*
 * 获取同一个hostname的Call最大并发数
 * @return Int64
 */
public func getMaxRequestsPerHost(): Int64
/*
 * 消执行所有运行中和预备运行的Call对象
 */
public func cancelAll(): Unit
/*
 * 获取等待运行的Call数量
 * @return Int64
 */
public func queuedCallsCount(): Int64
/*
 * 获取正在运行中的Call数量
 * @return Int64
 */
public func runningCallsCount(): Int64

```

#### interface EventListener

事件监听器

```
/*
 * 监听处理调用Call前
 * @param call: Call
 */
public func callStart(call: Call): Unit
/*
 * 监听处理调用Call后
 * @param call: Call
 */
public func callEnd(call: Call): Unit
/*
 * 监听处理调用dns解析前
 * @param call: Call
 * @param domainName: String
 */
public func dnsStart(call: Call, domainName: String): Unit
/*
 * 监听处理调用dns解析后
 * @param call: Call
 * @param domainName: String
 * @param allRoutes: ArrayList<Route>
 */
public func dnsEnd(call: Call, domainName: String, allRoutes: ArrayList<Route>): Unit
/*
 * 监听处理socket连接前
 * @param call: Call
 * @param socketAddress: SocketAddress
 */
public func connectStart(call: Call, socketAddress: SocketAddress): Unit
/*
 * 监听处理socket连接后
 * @param call: Call
 * @param socketAddress: SocketAddress
 * @param protocol: Protocol
 */
public func connectEnd(call: Call, socketAddress: SocketAddress, protocol: Protocol): Unit
/*
 * 监听处理tlsSocket连接前
 * @param call: Call
 */
public func secureConnectStart(call: Call): Unit
/*
 * 监听处理tlsSocket连接后
 * @param call: Call
 * @param tlsConfig: TlsClientConfig
 */
public func secureConnectEnd(call: Call, tlsConfig: TlsClientConfig): Unit
/*
 * 监听处理连接失败
 * @param call: Call
 * @param socketAddress: SocketAddress
 * @param protocol: Protocol
 * @param e: HttpException
 */
public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException): Unit
/*
 * 监听处理发送请求头前
 * @param call: Call
 */
public func requestHeadersStart(call: Call): Unit
/*
 * 监听处理发送请求头后
 * @param call: Call
 */
public func requestHeadersEnd(call: Call): Unit
/*
 * 监听处理发送请求体前
 * @param call: Call
 */
public func requestBodyStart(call: Call): Unit
/*
 * 监听处理发送请求体后
 * @param call: Call
 * @param byteCount: Int64
 */
public func requestBodyEnd(call: Call, byteCount: Int64): Unit
/*
 * 监听处理请求失败
 * @param call: Call
 * @param e: HttpException
 */
public func requestFailed(call: Call, e: HttpException): Unit
/*
 * 监听处理接受响应头前
 * @param call: Call
 */
public func responseHeadersStart(call: Call): Unit
/*
 * 监听处理接受响应头后
 * @param call: Call
 */
public func responseHeadersEnd(call: Call): Unit
/*
 * 监听处理接受响应体前
 * @param call: Call
 */
public func responseBodyStart(call: Call): Unit
/*
 * 监听处理接受响应体后
 * @param call: Call
 * @param byteCount: Int64
 */
public func responseBodyEnd(call: Call, byteCount: Int64): Unit
/*
 * 监听处理响应失败
 * @param call: Call
 * @param e: HttpException
 */
public func responseFailed(call: Call, e: HttpException): Unit

```

#### class Request <: ToString

请求对象

```
/*
 * 获取URL对象
 * @return URL
 */
public func getUrl(): URL
/*
 * 获取请求方法
 * @return String
 */
public func getMethod(): String
/*
 * 获取请求体
 * @return Option<RequestBody>
 */
public func getBody(): Option<RequestBody>
/*
 * 根据自身配置创建Builder
 * @return RequestBuilder
 */
public func newBuilder(): RequestBuilder
/*
 * 获取整个Header头对象
 * @return Header
 */
public func getHeaders(): Header
/*
 * 获取Header中key对应的 Option<String>
 * @return name: String
 */
public func getHeader(): name: String
/*
 * 获取Header中key对应的value,如果没有返回默认值
 * @return name: String, defaultValue: String
 */
public func getHeader(): name: String, defaultValue: String
/*
 * 获取请求中缓存控制对象
 * @return CacheControl
 */
public func getCacheControl(): CacheControl
/*
 * 获取标签
 * @param s: String
 * @return Tag
 */
public func getTag(s: String): Tag
/*
 * 移除标签
 * @param s: String
 */
public func removeTag(s: String): Unit

/*
 * 创建 Request 的Builder
 * @return RequestBuilder
 */
public static func builder(): RequestBuilder

```

#### class RequestBuilder

用于创建Request，用户通过链式调用配置其属性

```
/*
 * 根据字符串配置URL
 * @param url: String
 * @return RequestBuilder
 */
public func url(url: String): RequestBuilder
/*
 * 重载根据URL配置
 * @param url: URL
 * @return RequestBuilder
 */
public func url(url: URL): RequestBuilder
/*
 * 添加请求头key-value键值对
 * @param name: String
 * @param value: String
 * @return RequestBuilder
 */
public func header(name: String, value: String): RequestBuilder
/*
 * 配置请求方法 和请求体
 * @param method: String
 * @param body!: Option<RequestBody> = Option<RequestBody>.None
 * @return RequestBuilder
 * IllegalArgumentException - method为空 或 method 和 body不匹配
 */
public func method(method: String, body!: Option<RequestBody> = Option<RequestBody>.None): RequestBuilder
/*
 * 配置PUT请求方法 和请求体
 * @param body: RequestBody
 * @return RequestBuilder
 */
public func put(body: RequestBody): RequestBuilder
/*
 * 配置POST请求方法 和请求体
 * @param body: RequestBody
 * @return RequestBuilder
 */
public func post(body: RequestBody): RequestBuilder
/*
 * 配置PATCH请求方法 和请求体
 * @param body: RequestBody
 * @return RequestBuilder
 */
public func patch(body: RequestBody): RequestBuilder
/*
 * 配置DELETE请求方法 和请求体
 * @param body: Option<RequestBody>
 * @return RequestBuilder
 */
public func delete(body: Option<RequestBody>): RequestBuilder
/*
 * 配置GET请求方法
 * @return RequestBuilder
 */
public func get(): RequestBuilder
/*
 * 配置HEAD请求方法
 * @return RequestBuilder
 */
public func head(): RequestBuilder
/*
 * 创建Request
 * @param Request
 * @return RequestBuilder
 */
public func build(Request): RequestBuilder
/*
 * 移除请求头key对应的value
 * @param name: String
 * @return RequestBuilder
 */
public func removeHeader(name: String): RequestBuilder
/*
 * 配置请求头
 * @param header: Header
 * @return RequestBuilder
 */
public func header(header: Header): RequestBuilder
/*
 * 配置请求中缓存控制头
 * @param cacheControl: CacheControl
 * @return RequestBuilder
 */
public func cacheControl(cacheControl: CacheControl): RequestBuilder
/*
 * 设置标签
 * @param s: String
 * @return RequestBuilder
 */
public func tag(s: String): RequestBuilder


```

#### class Tag

标签

```
/*
 * 构造器
 * @param tag：String
 */
public init(tag：String) 


```

#### class MediaType <: ToString

媒体类型

```
/*
 * 获取主类型
 * @return String
 */
public func getType(): String
/*
 * 获取子类型
 * @return String
 */
public func getSubtype(): String
/*
 * 获取字符集
 * @return String
 */
public func getCharset(): String


/*
 * 解析字符串为MediaType对象，解析失败抛出异常
 * @param string: String
 * @return MediaType
 * @throw IllegalArgumentException
 */
public static func get(string: String): MediaType
/*
 * 解析字符串为MediaType对象，解析失败返回NONE
 * @param string: String
 * @return Option<MediaType>
 */
public static func parse(string: String): Option<MediaType>

```

#### interface RequestBody

请求体对象

```
/*
 * 获取请求体的请求体数据类型
 * @return Option<MediaType>
 */
public func contentType(): Option<MediaType>
/*
 * 获取请求体的长度
 * @return Int64
 */
public func getContentLength(): Int64
/*
 * 将请求体内容写入到sink对象中
 * @param sink: Sink
 */
public func writeTo(sink: Sink): Unit
/*
 * 获取请求体的输出流
 * @return InputStream
 */
public func get(): InputStream

```

#### class RealRequestBody <: RequestBody

```
/*
 * 创建请求内容为字符串的RequestBody
 * @param contentType: Option<MediaType>
 * @param content: String
 * @return RequestBody
 */
public static func create(contentType: Option<MediaType>, content: String): RequestBody
/*
 * 创建请求内容为Byte数组的RequestBody
 * @param contentType: Option<MediaType>
 * @param bytes: Array<Byte>
 * @return RequestBody
 */
public static func create(contentType: Option<MediaType>, bytes: Array<Byte>): RequestBody
/*
 * 创建请求内容为文件的RequestBody
 * @param contentType: Option<MediaType>
 * @param file: File
 * @return RequestBody
 */
public static func create(contentType: Option<MediaType>, file: File): RequestBody


```

#### class FormBody <: RequestBody

form表单格式的请求体

```
/*
 * 创建 FormBody 的Builder
 * @return FormBodyBuilder
 */
public static func builder(): FormBodyBuilder

```

#### class FormBodyBuilder <: Builder\<FormBody\>

```
/*
 * 返回构建的FormBody对象
 * @return FormBody
 */
public func build(): FormBody
/*
 * 添加配置表单的键值对
 * @param name: String
 * @param value: String
 * @return FormBodyBuilder
 */
public func add(name: String, value: String): FormBodyBuilder

```

#### class MultipartBody <: RequestBody

多类型格式的请求体

```
/*
 * 创建 MultipartBody 的Builder
 * @return MultipartBodyBuilder
 */
public static func builder(): MultipartBodyBuilder
/*
 * 获取boundary随机值
 * @return String
 */
public static func getBoundary(): String
/*
 * 获取所有添加的Part
 * @return ArrayList<Part>
 */
public static func getParts(): ArrayList<Part>
/*
 * 获取原始类型
 * @return MediaType
 */
public static func getType(): MediaType

```

#### class MultipartBodyBuilder <: Builder\<MultipartBody\>

```
/*
 * 返回构建的MultipartBody对象
 * @return FormBody
 * @throw IllegalStateException - 未添加part
 */
public func build(): FormBody
/*
 * 设置多请求类型，默认为multipart/mixed
 * @param contentType: MediaType
 * @return MultipartBodyBuilder
 * @throw IllegalArgumentException - 不符合multipart格式
 */
public func setType(contentType: MediaType): MultipartBodyBuilder
/*
 * 添加一个part
 * @param part: Part
 * @return MultipartBodyBuilder
 */
public func addPart(part: Part): MultipartBodyBuilder
/*
 * 根据body创建part对象并添加
 * @param body: RequestBody
 * @return MultipartBodyBuilder
 */
public func addPart(body: RequestBody): MultipartBodyBuilder
/*
 * 根据header, body创建part对象并添加，header不允许使用 Content-Type以及Content-Length
 * @param headers: Header
 * @param body: RequestBody
 * @return MultipartBodyBuilder
 */
public func addPart(headers: Header, body: RequestBody): MultipartBodyBuilder
/*
 * 创建表单类型的part并添加
 * @param name: String
 * @param value: String
 * @return MultipartBodyBuilder
 */
public func addFormDataPart(name: String, value: String): MultipartBodyBuilder
/*
 * 创建带文件的表单类型的part并添加
 * @param name: String
 * @param filename: String
 * @param body: RequestBody
 * @return MultipartBody
 */
public func addFormDataPart(name: String, filename: String, body: RequestBody): MultipartBody

```

#### class Part

```
/*
 * 根据header, body创建part对象
 * @param headers: Option<Header>
 * @param body: RequestBody
 * @return Part
 * @throw IllegalArgumentException - Header包含 Content-Type， Content-Length
 */
public static func create(headers: Option<Header>, body: RequestBody): Part
/*
 * 根据body创建part对象
 * @param body: RequestBody
 * @return Part
 */
public static func create(body: RequestBody): Part
/*
 * 创建表单类型的part
 * @param name: String
 * @param value: String
 * @return Part
 * @throw IllegalArgumentException - name为空
 */
public static func createFormData(name: String, value: String): Part
/*
 * 创建带文件的表单类型的part
 * @param name: String
 * @param filename: String
 * @param body: RequestBody
 * @return Part
 */
public static func addFormDataPart(name: String, filename: String, body: RequestBody): Part

```

#### class Response <: ToString

请求的响应

```
/*
 * 根据自身配置创建 Builder
 * @return ResponseBuilder
 */
public func newBuilder(): ResponseBuilder
/*
 * 获取对应的 Request 对象
 * @return Request
 */
public func getRequest(): Request
/*
 * 获取使用协议
 * @return Protocol
 */
public func getProtocol(): Protocol
/*
 * 获取状态码
 * @return Int64
 */
public func getCode(): Int64
/*
 * 获取报文消息
 * @return String
 */
public func getMessage(): String
/*
 * 请求是否成功
 * @return Bool
 */
public func isSuccess(): Bool
/*
 * 获取整个响应头
 * @return Header
 */
public func getHeaders(): Header
/*
 * 获取Header中key对应的value
 * @param name: String
 * @return Option<String>
 */
public func getHeader(name: String): Option<String>
/*
 * 获取Header中key对应的value,如果没有返回默认值
 * @param name: String
 * @param defaultValue: String
 * @return String
 */
public func getHeader(name: String, defaultValue: String): String
/*
 * 获取响应体
 * @return Option<ResponseBody>
 */
public func getBody(): Option<ResponseBody>
/*
 * 获取重定向的前置响应对象
 * @return Option<Response>
 */
public func getPrevResponse(): Option<Response>
/*
 * 是否是重定向响应
 * @return Bool
 */
public func isRedirect(): Bool
/*
 * 关闭响应体资源
 * @throw IllegalStateException - 无响应体
 */
public func close(): Unit
/*
 * 格式化输出
 * @return String
 */
public func toString(): String
/*
 * 获取缓存控制对象
 * @return CacheControl
 */
public func getCacheControl(): CacheControl
/*
 * 获取请求发送时间
 * @return Int64
 */
public func getSentRequestAtMillis(): Int64
/*
 * 获取响应方接受时间
 * @return Int64
 */
public func getReceivedResponseAtMillis(): Int64
/*
 * 获取网络响应，使用缓存时为None,对于条件请求networkResponse以及cacheResponse可能均不为None
 * @return Option<Response>
 */
public func getNetworkResponse(): Option<Response>
/*
 * 获取缓存中读取的响应，使用网络请求时为None, 对于条件请求networkResponse以及cacheResponse可能均不为None
 * @return Option<Response>
 */
public func getCacheResponse(): Option<Response>

/*
 * 创建 Response 的Builder
 * @return ResponseBuilder
 */
public static func builder(): ResponseBuilder

```

#### class ResponseBody <: Resource

响应体

```
/*
 * 构造器
 * @param contentType: String
 * @param contentLength: Int64
 * @param source: Source
 */
public init(contentType: String, contentLength: Int64, source: Source) 
/*
 * 获取响应体source
 * @return Source
 */
public func getSource(): Source
/*
 * 关闭响应体资源
 */
public func close(): Unit
/*
 * 响应体资源是否已关闭
 */
public func isClosed(): Unit
/*
 * 获取响应体长度
 * @return Int64
 */
public func getContentLength(): Int64
/*
 * 获取响应体类型
 * @return Option<MediaType>
 */
public func getContentType(): Option<MediaType>
/*
 * 解析响应体为字符串
 * @return String
 */
public func getString(): String

```

#### class ResponseBuilder

用于创建Response，通过链式调用配置其属性

```
/*
 * 通过配置项创建出核心类 Response
 * @return Response
 */
public func build(): Response
/*
 * 配置原请求对象
 * @param request: Request
 * @return ResponseBuilder
 */
public func request(request: Request): ResponseBuilder
/*
 * 配置http协议
 * @param protocol: Protocol
 * @return ResponseBuilder
 */
public func protocol(protocol: Protocol): ResponseBuilder
/*
 * 配置状态码
 * @param code: Int64
 * @return ResponseBuilder
 */
public func code(code: Int64): ResponseBuilder
/*
 * 配置状态信息
 * @param message: String
 * @return ResponseBuilder
 */
public func message(message: String): ResponseBuilder
/*
 * 重设响应头key-value键值对
 * @param name: String
 * @param value: String
 * @return ResponseBuilder
 */
public func header(name: String, value: String): ResponseBuilder
/*
 * 添加响应头key-value键值对
 * @param name: String
 * @param value: String
 * @return ResponseBuilder
 */
public func addHeader(name: String, value: String): ResponseBuilder
/*
 * 移除响应头key-value键值对
 * @param name: String
 * @return ResponseBuilder
 */
public func removeHeader(name: String): ResponseBuilder
/*
 * 配置重定向的前置响应对象。
 * @param prevResponse: Option<Response>
 * @return ResponseBuilder
 * @throw IllegalArgumentException - 响应对象的 body 不为 None
 */
public func prevResponse(prevResponse: Option<Response>): ResponseBuilder
/*
 * 配置响应体
 * @param body: ResponseBody
 * @return ResponseBuilder
 */
public func body(body: ResponseBody): ResponseBuilder
/*
 * 配置响应头
 * @param header: Header
 * @return ResponseBuilder
 */
public func header(header: Header): ResponseBuilder
/*
 * 配置请求发送时间
 * @param sentRequestAtMillis: Int64
 * @return ResponseBuilder
 */
public func sentRequestAtMillis(sentRequestAtMillis: Int64): ResponseBuilder
/*
 * 配置响应接受时间
 * @param receivedResponseAtMillis: Int64
 * @return ResponseBuilder
 */
public func receivedResponseAtMillis(receivedResponseAtMillis: Int64): ResponseBuilder
/*
 * 配置网络响应
 * @param cacheResponse: Option<Response>
 * @return ResponseBuilder
 * @throw IllegalArgumentException - 响应的body，networkResponse，cacheResponse，prevResponse不为None
 */
public func networkResponse(cacheResponse: Option<Response>): ResponseBuilder
/*
 * 配置缓存中读取的响应
 * @param networkResponse: Option<Response>
 * @return ResponseBuilder
 * @throw IllegalArgumentException - 响应的body，networkResponse，cacheResponse，prevResponse不为None
 */
public func cacheResponse(networkResponse: Option<Response>): ResponseBuilder


```

#### interface Source <: Resource

```
/*
 * 读取指定字节的数据
 * @param bytes: ByteArrayStream
 * @param byteCount: Int64
 * @return Int64
 */
public func read(bytes: ByteArrayStream, byteCount: Int64): Int64
/*
 * 关闭source
 */
public func close(): Unit
/*
 * source是否已关闭
 */
public func isClosed(): Unit


```

#### class OkBuffer <: Source

用于读取响应报文以及缓存数据的功能类

```
/*
 * 构造器 inputStream: 处理的输入流
 * @param inputStream: InputStream
 */
public init(inputStream: InputStream) 
/*
 * 按\r\n读取utf8字符串
 * @return String
 * @throw EOFExceptionException - 未找到 \r\n 抛出 EOFExceptionException
 */
public func readUtf8LineStrict(): String
/*
 * 在limit个字节内按\r\n读取utf8字符串
 * @param limit: Int64
 * @return String
 * @throw IllegalArgumentException -limit < 0 
 * @throw EOFExceptionException - 未找到 \r\n 抛出
 */
public func readUtf8LineStrict(limit: Int64): String
/*
 * 按\n读取utf8字符串
 * @return String
 * @throw EOFExceptionException - 未找到 \n 
 */
public func readUtf8Line(): String
/*
 * 在limit个字节内按\n读取utf8字符串
 * @param limit: Int64
 * @return String
 * @throw IllegalArgumentException - limit < 0
 * @throw EOFExceptionException - 未找到 \n 
 */
public func readUtf8Line(limit: Int64): String
/*
 * 忽略并跳过limit个Byte
 * @param limit: Int64
 * @throw IllegalArgumentException - limit < 0 
 * @throw EOFExceptionException - 无法读取到数据
 */
public func skipBuffer(limit: Int64): Unit
/*
 * 读取一个Byte
 * @return Byte
 * @throw EOFExceptionException - 无法读取到数据
 */
public func readByte(): Byte
/*
 * 从start到end的位置找b的偏移位置并读取数据到缓冲
 * @param b: Byte
 * @param start: Int64
 * @param end: Int64
 * @return Int64
 * IllegalArgumentException - start < 0 或者 end 比 start 小
 * @throw EOFExceptionException - 无法读取到数据
 */
public func indexOf(b: Byte, start: Int64, end: Int64): Int64


```

#### class OkGzipSource <: Source

解压缩gzip数据源

```
/*
 * source： 数据源
 * @param source: Source
 */
public init(source: Source) 


```

#### interface Sink

```
/*
 * 将buffer写入到sink中
 * @param bytes: Array<Byte>
 */
public func write(bytes: Array<Byte>): Unit
/*
 * 将数据从缓存中刷入流中
 */
public func flush(): Unit
/*
 * 关闭sink
 */
public func close(): Unit


```

#### RealBufferSink <: Sink

缓存流，将write数据缓存, 调用flush时刷入, 如果没有显式调用flush，则在close时刷入数据

```
/*
 * 构造器
 * @param sink: Sink
 */
public init(sink: Sink) 


```

#### class Chain

拦截器链

```
/*
 * 获取Transmitter对象
 * @param interceptors: ArrayList<Interceptor> 拦截器对象集合
 * @param transmitter: Transmitter
 * @param index: Int64 当前拦截器偏移值
 * @param request: Request 请求
 * @param call: Call 调用
 * @param exchange: Option<Exchange> http请求的传输的抽象
 * @param connectTimeout:Option<Duration> 读取超时时间
 * @param writeTimeout: Option<Duration> 写超时时间
 * @return Transmitter
 */
public init(interceptors: ArrayList<Interceptor>, transmitter: Transmitter , index:Int64, request: Request,
            call: Call, exchange: Option<Exchange>, connectTimeout:Option<Duration>, readTimeout:Option<Duration>,
            writeTimeout: Option<Duration>)
/*
 * 获取Transmitter对象
 * @return Transmitter
 */
public func getTransmitter(): Transmitter
/*
 * 获取请求对象
 * @return Request
 */
public func getRequest(): Request
/*
 * 获取Exchange对象
 * @return Exchange
 * @throw NoneValueException
 */
public func getExchange(): Exchange
/*
 * 执行拦截器
 * @param request: Request
 * @return Response
 */
public func proceed(request: Request): Response
/*
 * 执行拦截器重载
 * @param request: Request
 * @param transmitter: Transmitter
 * @param exchange: Option<Exchange>
 * @return Request
 * @throw NoneValueException - 偏移值越界
 */
public func proceed(request: Request,  transmitter: Transmitter, exchange: Option<Exchange>): Request
/*
 * 获取Call对象
 * @return Call
 */
public func getCall(): Call
/*
 * 获取连接对象
 * @return Option<Connection>
 */
public func getConnection(): Option<Connection>

```

#### interface Interceptor

默认添加拦截器按顺序有

1. RetryAndFollowUpInterceptor (负责 HTTP 请求的重定向功能，和重试机制)
2. BridgeInterceptor(负责桥接功能，把用户所构建的请求转换为真正的 Request，将服务器所返回的响应转换为用户所能够使用的 Response)
3. CacheInterceptor(负责缓存功能，负责缓存读取以及持久化, 以及协商缓存与强制缓存的缓存策略处理)
4. ConnectInterceptor(主要负责的是与服务器的连接的建立)
5. CallServerInterceptor(它真正实现了对服务器连接的读取)

```
/*
 * 拦截处理请求
 * @param chain: Chain
 * @return Response
 */
public func intercept(chain: Chain): Response

```

#### class Route <: Hashable & Equatable\<Route\>

连接服务器的路由

```
/*
 * address  包含服务器地址和连接协议的对象， inetSocketAddress 标准库SocketAddress类型表示socket地址
 * @param address: Address
 * @param inetSocketAddress: SocketAddress
 */
public init(address: Address, inetSocketAddress: SocketAddress) 
/*
 * 获取 Address 对象
 * @return Address
 */
public func getAddress(): Address
/*
 * 获取 SocketAddress 对象
 * @return SocketAddress
 */
public func getInetSocketAddress(): SocketAddress
/*
 * 获取 hashcode
 * @return Int64
 */
public func hashCode(): Int64
```

#### class Address <: Hashable & Equatable\<Route\>

包含服务器地址和连接协议的对象

```
/*
 * url  服务器URL资源， protocols 请求协议
 * @param url: URL
 * @param protocols: ArrayList<String>
 */
public init(url: URL, protocols: ArrayList<String>) 
/*
 * 获取 URL 对象
 * @return URL
 */
public func getUrl(): URL
/*
 * 获取协议
 * @return ArrayList<String>
 */
public func getProtocols(): ArrayList<String>
/*
 * 获取hashCode
 * @return Int64
 */
public func hashCode(): Int64
```

#### enum protocol <: ToString

/*
* H2_PRIOR_KNOWLEDGE
* @param HTTP_1_1
* @return HTTP_2
  */
  public func HTTP_1_0(HTTP_1_1): HTTP_2

```
/*
 * 获取协议字符串
 * @return String
 */
public func toString(): String

/*
 * 字符串转protocol对象
 * @param protocol: String
 * @return Protocol
 */
public static func get(protocol: String): Protocol


```

#### class Transmitter

OkHttp应用程序和网络层之间的桥梁。此类用于暴露出应用层中原始的连接、请求、响应和流数据

```
/*
 * client 客户端配置对象, call 请求的增强
 * @param client: OkHttpClient
 * @param call: Call
 */
public init(client: OkHttpClient, call: Call) 
/*
 * 关闭socket
 */
public func cancel(): Unit
/*
 * 是否已经关闭
 */
public func isCanceled(): Unit
/*
 * 进行准备连接前必要的初始化 如果已经进行过连接，可以复用则不再初始化
 * @param request: Request
 * @throw IllegalStateException
 */
public func prepareToConnect(request: Request): Unit
/*
 * 是否已经建立连接
 * @return Bool
 */
public func hasConnection(): Bool
/*
 * 是否已经建立传输通道
 * @return Bool
 */
public func hasExchange(): Bool
/*
 * 关闭传输通道
 * @throw IllegalStateException - 调用上未发现错误
 */
public func exchangeDoneDueToException(): Unit
/*
 * 由于异常关闭传输通道并取消连接
 */
public func noMoreExchanges(): Unit
/*
 * 是否可以重试
 * @return Bool
 * @throw NoneValueException -  未进行连接准备
 */
public func canRetry(): Bool


```

#### interface ExchangeCodec

对不同协议解析逻辑的封装

```
/*
 * 读取请求头
 * @param expectContinue: Bool
 * @return Option<ResponseBuilder>
 */
public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder>
/*
 * 解析请求体长度
 * @param response: Response
 * @return Int64
 */
public func reportedContentLength(response: Response): Int64
/*
 * 创建用于输出响应体的source对象
 * @param response: Response
 * @return Source
 */
public func openResponseBodySource(response: Response): Source
/*
 * 获取连接对象
 * @return Connection
 */
public func getConnection(): Connection
/*
 * 写入请求头报文
 * @param request: Request
 */
public func writeRequestHeaders(request: Request): Unit
/*
 * 将请求从缓存中刷入套接字并且结束请求标记不再进行新的传输
 * @return Int64
 */
public func finishRequest(): Int64
/*
 * 创建写入请求体的sink
 * @param request: Request
 * @return Sink
 */
public func createRequestBody(request: Request): Sink
/*
 * 将请求从缓存中刷入套接字
 */
public func flushRequest(): Unit
/*
 * 获取尾部Header
 * @return Header
 */
public func getTrailers(): Header
/*
 * 关闭socket
 */
public func cancel(): Unit

```

#### class Exchange

一次完整的http请求的传输的抽象对象

```
/*
 * 构造器
 * @param transmitter: Transmitter
 * @param call: Call
 * @param finder: ExchangeFinder
 * @param codec: ExchangeCodec
 */
public init(transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec) 
/*
 * 读取请求头
 * @param expectContinue: Bool
 * @return Option<ResponseBuilder>
 * @throw HttpException
 */
public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder>
/*
 * 解析并创建响应体
 * @param response: Response
 * @return ResponseBody
 * @throw HttpException
 */
public func openResponseBody(response: Response): ResponseBody
/*
 * 获取连接
 * @return Connection
 */
public func getConnection(): Connection
/*
 * 关闭通道
 * @return Bool
 */
public func cancel(): Bool
/*
 * 暴力关闭当前数据通道，会导致该通道依赖的流也无法使用
 */
public func detachWithViolence(): Unit
/*
 * 标记为此传输通道不再可用
 * @return Bool
 */
public func noNewExchangesOnConnection(): Bool
/*
 * 无请求体发送报文
 */
public func noRequestBody(): Unit
/*
 * 获取尾部Header
 * @return Header
 */
public func getTrailers(): Header
/*
 * 创建写入请求体的sink
 * @param request: Request
 * @return Sink
 */
public func createRequestBody(request: Request): Sink
/*
 * 写入请求头报文
 * @param request: Request
 * @throw HttpException
 */
public func writeRequestHeaders(request: Request): Unit
/*
 * 将请求从缓存中刷入套接字
 * @throw HttpException
 */
public func flushRequest(): Unit
/*
 * 将请求从缓存中刷入套接字并且结束请求标记不再进行新的传输
 * @throw HttpException
 */
public func finishRequest(): Unit

```

#### class Http1ExchangeCodec <: ExchangeCodec

处理Http1协议解析逻辑

```
/*
 * 构造器
 * @param client: OkHttpClient
 * @param realConnection: Connection
 * @param source: OkBuffer
 * @param sink: BufferedOutputStream
 */
public init(client: OkHttpClient, realConnection: Connection, source: OkBuffer, sink: BufferedOutputStream) 
/*
 * flush request
 */
public func flushRequest(): Unit
/*
 * 结束request
 */
public func finishRequest(): Unit
/*
 * 获取Trailer
 * @return Header
 */
public func getTrailers(): Header
/*
 * 写header
 * @param request: Request
 */
public func writeRequestHeaders(request: Request): Unit
/*
 * 写request
 * @param headers: Header
 * @param requestLine: String
 */
public func writeRequest(headers: Header, requestLine: String): Unit
/*
 * The Function is readResponseHeaders
 * @param expectContinue: Bool
 * @return Type of ResponseBuilder
 */
public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder>
/*
 * create body
 * @param request: Request
 * @return Sink
 */
public func createRequestBody(request: Request): Sink
/*
 * The Function is reportedContentLength
 * @param response: Response
 * @return Type of Int64
 */
public func reportedContentLength(response: Response): Int64
/*
 * openResponseBodySource
 * @param response: Response
 * @return Source
 */
public func openResponseBodySource(response: Response): Source
/**
  * The Function is getConnection
  *
  * @return Type of Connection
  */
public func getConnection(): Connection
/**
  * The Function is cancel
  *
  * @return Type of Unit
  */
public func cancel(): Unit
```

#### class Http2ExchangeCodec <: ExchangeCodec

处理Http2协议解析逻辑

```
/*
 * 构造器
 * @param client: OkHttpClient
 * @param realConnection: Connection
 * @param http2Connection: H2Connection
 */
public init(client: OkHttpClient, realConnection: Connection, http2Connection: H2Connection) 
/*
 * 获取Header
 * @param expectContinue: Bool
 * @return ResponseBuilder
 */
public func readResponseHeaders(expectContinue: Bool): Option<ResponseBuilder>
/*
 * Http2 的 Header 转换为标准Header并以ResponseBuilder形式返回
 * @param headerBlock: Header
 * @param protocol: Protocol
 * @return ResponseBuilder
 */
public static func readHttp2HeadersList(headerBlock: Header, protocol: Protocol): ResponseBuilder
/*
 * 获取Trailer
 * @return Header
 */
public func getTrailers(): Header
/*
 * 获取ContentLength
 * @param response: Response
 * @return Int64
 */
public func reportedContentLength(response: Response): Int64
/*
 * 获取ResponseBodySource
 * @param response: Response
 * @return Source
 */
public func openResponseBodySource(response: Response): Source
/*
 * 获取Connection
 * @return Connection
 */
public func getConnection(): Connection
/*
 * cancel
 */
public func cancel(): Unit
/*
 * 创建RequestBody
 * @param request: Request
 * @return Sink
 */
public func createRequestBody(request: Request): Sink
/*
 * 写Header
 * @param request: Request
 */
public func writeRequestHeaders(request: Request): Unit
/*
 * flush request
 */
public func flushRequest(): Unit
/*
 * finish request
 * @param 
 * @return 
 */
public func finishRequest(): Unit
```

#### class Connection

socket 以及 http1连接

```
/*
 * 构造器  connectionPool 连接池对象， route 路由对象
 * @param connectionPool: ConnectionPool
 * @param route: Route
 */
public init(connectionPool: ConnectionPool, route: Route) 
/*
 * 获取协议
 * @return Protocol
 */
public func getProtocol(): Protocol
/*
 * 获取该连接关联的所有Transmitter实例
 * @return ArrayList<Transmitter>
 */
public func getTransmitters(): ArrayList<Transmitter>
/*
 * 标记该连接上不再创建新的传输
 */
public func noExchanges(): Unit
/*
 * 获取socket
 * @return Option<OKSocket>
 */
public func getSocket(): Option<OKSocket>
/*
 * 获取路由对象
 * @return Route
 */
public func getRoute(): Route
/*
 * 连接是否健康可用
 * 未进行连接时抛出异常
 * @return Bool
 * @NoneValueExcption
 */
public func isHealthy(): Bool
/*
 * 连接是否支持多路复用
 * @return Bool
 */
public func isMultiplexed(): Bool
/*
 * 设置h2连接创建最大的流
 * @param h2: H2Connection
 * @return Bool
 */
public func onSettings(h2: H2Connection): Bool
/*
 * 开始连接
 * @param connectTimeout: Option<Duration>
 * @param readTimeout: Option<Duration>
 * @param writeTimeout: Option<Duration>
 * @param connectionRetryEnabled: Bool
 * @param eventListener: EventListener
 * @param call: Call
 * @throw ConnectException
 */
public func connect(connectTimeout: Option<Duration>, readTimeout: Option<Duration>, writeTimeout: Option<Duration>, connectionRetryEnabled: Bool, eventListener: EventListener, call: Call)): Unit
/*
 * 关闭socket
 */
public func cancel(): Unit

```

#### class H2Connection

http2连接

```
/*
 * 构造器
 * @param socket: SocketClient
 * @param sink: BufferedOutputStream
 * @param source: OkBuffer
 * @param listener !: Option<Connection> = Option<Connection>.None
 */
public init(socket: SocketClient, sink: BufferedOutputStream, source: OkBuffer,  listener !: Option<Connection> = Option<Connection>.None) 
/*
 * 作用为启动连接, 初始化设置,发送初始帧并开启读取子线程， 对象创建后需要优先调用，否则在后续使用出现未知问题
 * @throw SocketException
 */
public func start(): Unit
/*
 * 获取在该连接开启的的可用Stream流数量
 * @return Int64
 */
public func openStreamCount(): Int64
/*
 * 关闭连接, 并移除stream
 */
public func close(): Unit
/*
 * 发送 data 帧, outFinished: 是否是endStream 帧
 * @param streamId: UInt32
 * @param outFinished: Bool
 * @param buffer: ByteArrayStream
 * @param length: Int64
 * @throw SocketException
 */
public func writeData(streamId: UInt32, outFinished: Bool, buffer: ByteArrayStream, length: Int64): Unit
/*
 * 连接是否健康
 * 未进行连接时抛出异常
 * @return Bool
 */
public func isHealthy(): Bool
/*
 * 发送GOAway帧,准备关闭连接
 * @param statusCode: ErrorCode
 * @throw SocketException
 */
public func shutdownConn(statusCode: ErrorCode): Unit
/*
 * 覆盖设置并发送Settings帧
 * @param settings: Settings
 * @throw SocketException - socket关闭
 * @throwConnectionShutdownException - connection shutdown
 */
public func setSettings(settings: Settings): Unit
/*
 * 创建H2Stream对象
 * @param request: Request
 * @return H2Stream
 * @throw SocketException - socket关闭
 * @throwConnectionShutdownException - connection shutdown
 */
public func newStream(request: Request): H2Stream
/*
 * 可创建Stream数最大值
 * @return Int64
 */
public func getMaxConcurrentStreams(): Int64
/*
 * 刷入writer的缓存
 * @return Int64
 * @throw SocketException - socket关闭
 */
public func flush(): Int64

```

#### class Settings

http2 连接 settings帧 配置项
id对象配置项常量为
HEADER_TABLE_SIZE = 1 (报头表的最大字节数)
ENABLE_PUSH = 2 (服务器推送)
MAX_CONCURRENT_STREAMS = 4 (最大创建流数)
MAX_FRAME_SIZE = 5 (单帧负载最大字节值)
MAX_HEADER_LIST_SIZE = 6 (报头集合的最大字节数)
INITIAL_WINDOW_SIZE = 7 (连接初始的流量窗口字节数)

```
/*
 * 设置配置项参数
 * @param id: Int64
 * @param value: Int64
 * @return Settings
 */
public func setting(id: Int64, value: Int64): Settings
/*
 * 该id是否进行了配置
 * @param id: Int64
 * @return Bool
 */
public func isSet(id: Int64): Bool
/*
 * 获取该id配置的值
 * @param id: Int64
 * @return Int64
 */
public func get(id: Int64): Int64
/*
 * 已配置项参数的数量
 * @return Int64
 */
public func size(): Int64
/*
 * 获取id为1的配置参数
 * @return Int64
 */
public func getHeaderTableSize(): Int64
/*
 * 获取id为4的配置参数
 * @return Int64
 */
public func getMaxConcurrentStreams(): Int64
/*
 * 获取id为5的配置参数
 * @return Int64
 */
public func getMaxFrameSize(): Int64
/*
 * 获取id为7的配置参数
 * @return Int64
 */
public func getInitialWindowSize(): Int64
/*
 * 用新的settings对象合并覆盖自身
 * @param other: Settings
 */
public func merge(other: Settings): Unit

```

#### class H2Stream

http2流

```
/*
 * 获取关联sink
 * @return Sink
 */
public func getSink(): Sink
/*
 * 获取关联Source
 * @return Source
 */
public func getSource(): Source
/*
 * 获取StreamId
 * @return UInt32
 */
public func getId(): UInt32
/*
 * 获取错误code
 * @return Option<ErrorCode>
 */
public func getErrorCode(): Option<ErrorCode>
/*
 * 发送Reset_Stream帧并从连接中移除stream
 * @param rstStatusCode: ErrorCode
 * @param errorException: String
 * @throw SocketException - socket关闭
 */
public func close(rstStatusCode: ErrorCode, errorException: String): Unit
/*
 * 开启子线程发送Reset_Stream帧并从连接中移除stream
 * @param rstStatusCode: ErrorCode
 * @return Bool
 * @throw SocketException - socket关闭
 */
public func closeLater(rstStatusCode: ErrorCode): Bool
/*
 * 获取H2连接对象
 * @return H2Connection
 */
public func getConnection(): H2Connection
/*
 * 阻塞线程直到获取响应的Header
 * @return Header
 * @StreamResetException 接收到stream reset错误帧
 * @HttpException - 接收到其他stream错误帧
 */
public func takeHeaders(): Header
/*
 * Data帧中添加尾部的Header
 * @param trailers: Header
 * @IllegalStateException data数据发送已完成，不允许发送trailers
 * @IllegalArgumentException - trailers size = 0
 */
public func enqueueTrailers(trailers: Header): Unit
/*
 * 获取响应的尾部Header
 * @return Header
 * @StreamResetException 接收到stream reset错误帧
 * @HttpException - 接收到其他stream错误帧
 * @IllegalStateException - 还未读取data帧，无法获取trailers
 */
public func getTrailers(): Header
/*
 * stream是否开启中
 * @return Bool
 */
public func isOpen(): Bool

```

#### enum errorCode

HTTP2错误码， 从Reset_Stream帧或GOAway帧中获取

```
NO_ERROR|

PROTOCOL_ERROR|

INTERNAL_ERROR|

FLOW_CONTROL_ERROR|

REFUSED_STREAM|

CANCEL|

COMPRESSION_ERROR|

CONNECT_ERROR|

ENHANCE_YOUR_CALM|

INADEQUATE_SECURITY|

HTTP_1_1_REQUIRED

```
```
/*
 * 获取errorCode id
 * @return Int64
 */
public func getCode(): Int64
/*
 * 获取errorCode 字符串
 * @return String
 */
public func toString(): String

/*
 * 根据errorCode id 获取errorCode 对象
 * @param errorCodeInt: Int64
 * @return Option<ErrorCode>
 */
public static func fromHttp2(errorCodeInt: Int64): Option<ErrorCode>

```

#### class OKSocket <: Resource & InputStream & OutputStream

包装了SocketClient,用于支持socket被缓冲流包装时仍然具备使用读写超时的能力

```
/*
 * 构造器
 * @param client: SocketClient
 * @param readTimeOut: Option<Duration>
 * @param writeTimeOut: Option<Duration>
 */
public init(client: SocketClient, readTimeOut: Option<Duration>, writeTimeOut: Option<Duration>) 

```

#### enum SocketClient <: Resource

| SocketC(Socket)
| TlsC(TlsSocket)

封装 TlsSocket 和 Socket 便于提供统一接口

```
/*
 * 进行socket连接
 * @throw SocketTimeoutException - 当连接超时时，抛出异常
 * @throw SocketException - 当 connect 出现系统错误时，或当 socket 已关闭或已连接，
 * 或地址大小与ipv4或ipv6不匹配，或者发生了一些系统错误时，抛出
 * @throw TlsException - 当连接失败时抛出异常
 */
public func connect(): Unit
/*
 * 在指定时间内进行socket的连接,超时抛出SocketTimeoutException异常
 * @param timeout: Duration
 * @throw SocketTimeoutException - 如果 timeout 小于等于 0，直接抛出异常；如果大于 0，
 * 连接超时后抛出异常
 * @throw SocketException - 当 connect 出现系统错误时，或当 socket 已关闭或已连接，
 * 或地址大小与ipv4或ipv6不匹配，或者发生了一些系统错误时，抛出
 * @throw TlsTimeoutException - 如果 timeout 小于等于 0，直接抛出异常；如果大于 0，TLS
 * 握手连接超时抛出异常
 * @throw TlsException - 当非超时而连接失败时抛出异常
 */
public func connect(timeout: Duration): Unit
/*
 * 从已建立的 Socket 连接中读取数据，存放到入参 buffer 中
 * @param buffer: Array<Byte>
 * @return Int64
 * @throw SocketTimeoutException - 当读取超时时，抛出异常
 * @throw SocketException - 当初始化 socket 缓冲区失败，或者缓冲区为空，或者 socket 已
 * 关闭或未连接，或者发生了一些系统错误时，抛出异常
 * @throw TlsException - 当读取失败时抛出异常
 */
public func read(buffer: Array<Byte>): Int64
/*
 * 在指定时间内从已建立的 Socket 连接中读取数据，存放到入参 buffer 中, 超时抛出SocketTimeoutException异常
 * @param buffer: Array<Byte>
 * @param timeout: Duration
 * @return Int64
 * @throw SocketTimeoutException - 如果 timeout 小于 0，直接抛出异常；如果等于 0，读取
 * 失败则抛出异常
 * @throw SocketException - 当初始化 socket 缓冲区失败，或者缓冲区为空，或者 socket 已
 * 关闭或未连接，或者发生了一些系统错误时，抛出异常
 * @throw TlsTimeoutException - 如果 timeout 小于等于 0，直接抛出异常；如果大于 0，TLS
 * 读取时抛出异常
 * @throw TlsException - 当非超时而读取失败时抛出异常
 */
public func read(buffer: Array<Byte> , timeout: Duration): Int64
/*
 * 将入参 buffer 中存储的数据写入到 Socket 连接中
 * @param buffer: Array<Byte>
 * @throw SocketTimeoutException - 如果 timeout 小于 0，直接抛出异常；如果等于 0，读取
 * 失败则抛出异常
 * @throw SocketException - 当初始化 socket 缓冲区失败，或者缓冲区为空，或者 socket 已
 * 关闭或未连接，或者发生了一些系统错误时，抛出异常
 * @throw TlsException - 当写入失败时抛出异常
 */
public func write(buffer: Array<Byte>): Unit
/*
 * 在指定时间内将入参 buffer 中存储的数据写入到 Socket 连接中 , 超时抛出SocketTimeoutException异常
 * @param buffer: Array<Byte>
 * @param timeout: Duration
 * @throw SocketTimeoutException - 如果 timeout 小于 0，直接抛出异常；如果等于 0，读取
 * 失败则抛出异常
 * @throw SocketException - 当初始化 socket 缓冲区失败，或者缓冲区为空，或者 socket 已
 * 关闭或未连接，或者发生了一些系统错误时，抛出异常
 * @throw SocketException - 当初始化 socket 缓冲区失败，或者缓冲区为空，或者 socket 已
 * 关闭或未连接，或者发生了一些系统错误时，抛出异常
 * @throw TlsTimeoutException - 如果 timeout 小于等于 0，直接抛出异常；如果大于 0，TLS
 * 写入时抛出异常
 * @throw TlsException - 当非超时而写入失败时抛出异常
 */
public func write(buffer: Array<Byte> , timeout: Duration): Unit


```

#### class ConnectionPool

连接池

```
/*
 * maxIdleConnections 最大空闲连接数, 默认为5 keepAliveDurationNs 连接最大空闲保持存活时间 默认为5分钟
 * @param maxIdleConnections!: Int64 = 5
 * @param keepAliveDurationNs!: Duration = Duration.minute*5
 */
public init(maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute*5) 
/*
 * 获取当前空闲连接数
 * @return Int64
 */
public func idleConnectionCount(): Int64
/*
 * 移除并关闭所有空闲连接
 */
public func evictAll(): Unit
/*
 * 记录连接失败的路由
 * @param failedRoute: Route
 */
public func connectFailed(failedRoute: Route): Unit

```

#### class StatusLine <: ToString

解析报文第一行StatusLine

```
/*
 * 构造器
 * @param protocol: Protocol
 * @param code: Int64
 * @param message: String
 */
public init(protocol: Protocol, code: Int64, message: String) 

/*
 * 解析字符串为StatusLine, 如果格式不正确则抛出异常
 * @param statusLine: String
 * @return StatusLine
 * @ProtocolException - 报文格式错误
 */
public static func parse(statusLine: String): StatusLine

```

#### class CookieUtil

解析cookie

```
/*
 * 解析所有cookie
 * @param url: URL
 * @param headers: Header
 * @return ArrayList<Cookie>
 */
public static func parseAll(url: URL, headers: Header): ArrayList<Cookie>
/*
 * 解析单个cookie,如果不合法返回None
 * @param url: URL
 * @param setCookie: String
 * @return Option<Cookie>
 */
public static func parse(url: URL, setCookie: String): Option<Cookie>

```

#### interface CookieJar

```
/*
 * 保存cookie
 * @param url: URL
 * @param cookies: Array<Cookie>
 */
public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit
/*
 * 从CookieJar中获取cookie
 * @param url: URL
 * @return Array<Cookie>
 */
public func loadForRequest(url: URL): Array<Cookie>


```

#### class Cache <: Resource

处理http缓存功能

```
/*
 * directoryPath: 缓存目录地址, maxSize: 缓存大小，单位byte
 * @param directoryPath: String
 * @param maxSize: Int64
 * @throw FSException
 * @throw IllegalStateException
 */
public init(directoryPath: String, maxSize: Int64) 
/*
 * 获取缓存目录
 * @return Directory
 */
public func getDirectory(): Directory
/*
 * 获取最大可用缓存值
 * @return Int64
 */
public func getMaxSize(): Int64
/*
 * 删除缓存
 */
public func evictAll(): Unit
/*
 * 关闭cache 删除缓存
 * @return Directory
 */
public func delete(): Directory
/*
 * 获取已缓存url的迭代器
 * @return Iterator<String>
 */
public func urls(): Iterator<String>
/*
 * 刷新缓存流到缓存文件中
 */
public func flush(): Unit
/*
 * 初始化，如过有读取缓存文件则读取保存于内存中，没有则构建缓存文件
 */
public func initialize(): Unit
/*
 * 关闭cache
 */
public func close(): Unit
/*
 * 获取大小
 * @param 
 * @return 
 */
public func getSize(): Int64
/*
 * 关闭状态
 * @param 
 * @return 
 */
public func isClosed(): Bool
/*
 * 根据url进行md5加密，用于缓存文件的文件名
 * @param url: URL
 * @return String
 */
public static func key(url: URL): String

```

#### class CacheControl <: ToString

缓存控制分别为客户端请求控制和服务端相应控制，其中启用参数各有异同,部分如下：

请求
+ no-cache
+ no-store
+ max-age = [秒]
+ max-stale(=[秒])
+ min-fresh(=[秒])
+ no-transform
+ only-if-cached()

响应
+ public
+ private
+ no-cache
+ no-store
+ no-transform
+ must-revalidate
+ max-age = [秒]
+ s-maxage = [秒]

```
/*
 * directoryPath: 缓存目录地址, maxSize: 缓存大小，单位byte
 * @param directoryPath: String
 * @param maxSize: Int64
 */
public init(directoryPath: String, maxSize: Int64) 
/*
 * 是否使用缓存
 * @return Bool
 */
public func noCache(): Bool
/*
 * 是否不保存缓存或请求
 * @return Bool
 */
public func noStore(): Bool
/*
 * 缓存的最大Age值，单位：秒
 * @return Int64
 */
public func maxAgeSeconds(): Int64
/*
 * 已过期缓存的最大Age值，单位：秒
 * @return Int64
 */
public func maxStaleSeconds(): Int64
/*
 * 公共缓存的最大Age值，单位：秒
 * @return Int64
 */
public func sMaxAgeSeconds(): Int64
/*
 * 期望指定时间内的响应，单位：秒
 * @return Int64
 */
public func minFreshSeconds(): Int64
/*
 * 是否私有缓存
 * @return Bool
 */
public func isPrivate(): Bool
/*
 * 是否公共缓存
 * @return Bool
 */
public func isPublic(): Bool
/*
 * 过期缓存必须再次校验
 * @return Bool
 */
public func mustRevalidate(): Bool
/*
 * 只使用缓存
 * @return Int64
 */
public func onlyIfCached(): Int64
/*
 * 不允许更改请求或响应
 * @return Bool
 */
public func noTransform(): Bool
/*
 * 资源保持不变
 * @return Bool
 */
public func immutable(): Bool
/*
 * 期望指定时间内的响应
 * @return Int64
 */
public func minFreshSeconds(): Int64

/*
 * 创建 CacheControl 的Builder
 * @return CacheControlBuilder
 */
public static func builder(): CacheControlBuilder
/*
 * 从Header中解析Cache-control头的值并返回CacheControl对象
 * @return header: Header
 */
public static func parse(): header: Header

```

#### class CacheControlBuilder

用于创建客户端缓存控制

```
/*
 * 配置是否使用缓存
 * @return CacheControlBuilder
 */
public func noCache(): CacheControlBuilder
/*
 * 是否不保存缓存或请求
 * @return CacheControlBuilder
 */
public func noStore(): CacheControlBuilder
/*
 * 配置使用缓存的最大Age值，单位：秒
 * @param Int64
 * @return CacheControlBuilder
 * @throw IllegalArgumentException maxAge < 0
 */
public func maxAge(maxAge: Int64): CacheControlBuilder
/*
 * 配置使用已过期缓存的最大Age值，单位：秒
 * @param Int64
 * @return CacheControlBuilder
 * @throw IllegalArgumentException maxStale < 0
 */
public func maxStale(maxStale: Int64): CacheControlBuilder
/*
 * 配置期望指定时间内的缓存，单位：秒
 * @param Int64
 * @return CacheControlBuilder
 * @throw IllegalArgumentException minFresh: < 0
 */
public func minFresh(minFresh: Int64): CacheControlBuilder
/*
 * 配置只使用缓存
 * @return CacheControlBuilder
 */
public func onlyIfCached(): CacheControlBuilder
/*
 * 配置不允许更改请求
 * @return CacheControlBuilder
 */
public func noTransform(): CacheControlBuilder
/*
 * 配置资源保持不变
 * @return CacheControlBuilder
 */
public func immutable(): CacheControlBuilder
/*
 * 创建CacheControl对象
 * @return CacheControlBuilder
 */
public func build(): CacheControlBuilder

```

#### class RouteException

```
/*
 * 构造函数
 */
public init(message: String, e: HttpException)
/*
 * 获取第一次HttpException
 * @return HttpException
 */
public func getFirstConnectException(): HttpException
/*
 * 获取最后一次HttpException
 * @return HttpException
 */
public func getLastConnectException(): HttpException
```

#### 全局函数

```
/*
 * 获取简单的使用内存的cookieJar, cookie保存于内存中,无持久化
 * @return CookieJar
 */
public func getSimpleCookieJar(): CookieJar
/*
 * 解析域名
 * @param net: SocketNet
 * @param domain: String
 * @return ArrayList<(SocketAddressKind, Array<UInt8>)>
 */
public func resolveDomain(net: SocketNet, domain: String): ArrayList<(SocketAddressKind, Array<UInt8>)>
```
