# 三方库设计说明

## 1 需求场景分析

处理网络请求的轻量级框架，可以有效地执行HTTP返回响应。

## 2 三方库对外提供的特性

1. 支持步和异步请求，支持自定义调度器维护请求
2. 支持全局配置，例如连接超时，请求方式，使用链式调用来配置对象
3. 支持http1.1 和 http2 协议
4. 支持 tls， 对于https协议默认开启tls
5. 支持自定义拦截器
6. 支持创建文件, multipart, 表单等多种请求体
7. 支持连接复用
8. 支持cookie的管理使用
9. 使用连接池减少请求延迟，处理过时连接
10. 默认开启gzip压缩
11. 支持事件监听


## 3 License分析

apache 2.0 License


## 4 依赖分析

依赖仓颉标准库 time， collection， http， socket， tls， io， fs， regex， sync， math， convert等

## 5 接口设计

### 5.1 api接口

#### Interface Builder

建造者模式，用于创建可链式调用配置项的配置类，最终创建出核心类。

| 成员函数      | 入参  | 返回值      | 作用描述     |
|-----------|-----|----------|----------|
| build     | 无   | T        | 创建出核心类。  |


#### class okhttpClient

Call的工厂类，可用于发送 HTTP 请求并读取其响应，外观形式上等同于http客户端，每个客户端都拥有自己的连接池和线程池。重用连接可减少延迟并节省内存。

| 成员函数                        | 入参               | 返回值                                             | 作用描述           |
|-----------------------------|------------------|-------------------------------------------------|----------------|
| newCall                     | request: Request | Call                                            | 增强请求对象         |
| getFollowRedirects          | 无                | Bool                                            | 请求是否允许重定向      |
| getRetryOnConnectionFailure | 无                | Bool                                            | 连接失败是否允许重试     |
| getConnectionPool           | 无                | Option\<ConnectionPool\>                        | 获取客户端使用的连接池对象  |
| getDispatcher               | 无                | Dispatcher                                      | 获取客户端分发器       |
| getInterceptors             | 无                | ArrayList\<Interceptor\>                        | 获取自定义连接前处理拦截器  |
| getNetworkInterceptors      | 无                | getNetworkInterceptors                          | 获取自定义连接后处理拦截器  |
| getCookieJar                | 无                | CookieJar                                       | 获取CookieJar    |
| getConnectTimeout           | 无                | Option\<Duration\>                              | 获取连接超时时间       |
| getReadTimeout              | 无                | Option\<Duration\>                              | 获取读取连接超时时间     |
| getWriteTimeout             | 无                | Option\<Duration\>                              | 获取写连接超时时间      |
| getProtocols                | 无                | ArrayList\<String\>                             | 获取使用的http协议    |
| getTlsConfig                | 无                | Option\<TlsClientConfig\>                       | 获取tls的CA证书     |
| getAuthenticator            | 无                | (Option\<Route\>, Response)-> Option\<Request\> | 获取鉴权配置         |
| getFollowSslRedirects       | 无                | Bool                                            | 获取是否允许跨协议进行重定向 |
| getEventListener            | 无                | EventListener                                   | 获取事件监听器        |
| getCache                    | 无                | Option\<Cache\>                                 | 获取缓存对象         |

| 静态函数      | 入参   | 返回值                  | 作用描述                      |
|-----------|------|----------------------|---------------------------|
| builder   | 无    | OkHttpClientBuilder  | 创建 OkHttpClient 的Builder  |


#### class okhttpClientBuilder

用于创建okhttpClient，用户通过链式调用配置其属性

| 成员函数                     | 入参                                                              | 返回值                 | 作用描述                                                                                      |
|--------------------------|-----------------------------------------------------------------|---------------------|-------------------------------------------------------------------------------------------|
| init                     | 无                                                               | 无                   | 无参构造                                                                                      |
| build                    | 无                                                               | OkHttpClient        | 通过配置项创建出核心类 OkHttpClient                                                                  |
| dispatcher               | dispatcher: Dispatcher                                          | OkHttpClientBuilder | 配置个性化的请求分发器                                                                               |
| followRedirects          | followRedirects: Bool                                           | OkHttpClientBuilder | 配置是否允许重定向, 默认为true                                                                        |
| retryOnConnectionFailure | retryOnConnectionFailure: Bool                                  | OkHttpClientBuilder | 配置连接失败是否允许重试,默认为true                                                                      |
| connectionPool           | connectionPool: Option\<ConnectionPool\>                        | OkHttpClientBuilder | 配置客户端使用个性化的连接池对象 ，默认最大空闲数为5，最大空闲时间为5分钟                                                    |
| addInterceptor           | interceptor: Interceptor                                        | OkHttpClientBuilder | 添加用户自定义的连接前处理的拦截器                                                                         |
| addNetworkInterceptor    | interceptor: Interceptor                                        | OkHttpClientBuilder | 添加用户自定义的连接后处理的拦截器                                                                         |
| connectTimeout           | connectTimeout: Duration                                        | OkHttpClientBuilder | 配置连接超时时间                                                                                  |
| readTimeout              | readTimeout: Duration                                           | OkHttpClientBuilder | 配置读取连接超时时间                                                                                |
| cookieJar                | cookieJar: CookieJar                                            | OkHttpClientBuilder | 配置cookieJar，默认使用cookieJar不保存cookie，也无法获取cookie，可以使用全局函数getSimpleCookieJar获取轻量的cookieJar对象 |
| writeTimeout             | writeTimeout: Duration                                          | OkHttpClientBuilder | 配置读取连接超时时间                                                                                |
| protocols                | protocols: ArrayList\<String\>                                  | OkHttpClientBuilder | 参数 protocols 使用协议的集合, 支持 http/1.1, http2 以及 h2_prior_knowledge                            |
| tlsConfig                | path: String                                                    | OkHttpClientBuilder | 开启tls, 配置tls 的 CA证书路径                                                                     |
| authenticator            | authenticator: (Option\<Route\>, Response) -> Option\<Request\> | OkHttpClientBuilder | 开启鉴权配置 (如果 code 返回 401 则需要鉴权配置), 如果lambda返回None则不再进行重试, 否则进行鉴权配置后重试请求                     |
| followSslRedirects       | followSslRedirects: Bool                                        | OkHttpClientBuilder | 配置是否允许跨协议进行重定向                                                                            |
| eventListener            | listener: EventListener                                         | OkHttpClientBuilder | 配置自定义事件监听器                                                                                |
| cache                    | cache: Option\<Cache\>                                          | OkHttpClientBuilder | 配置使用缓存                                                                                    |

#### interface Call

对已准备好执行的请求进行增强行后再执行，已经请求完成过一次的 call 无法再次执行

| 成员函数         | 入参                         | 返回值      | 作用描述                   |
|--------------|----------------------------|----------|------------------------|
| getRequest   | 无                          | Request  | 获取封装的请求对象              |
| execute      | 无                          | Response | 同步进行请求                 |
| enqueue      | responseCallback: Callback | Unit     | 异步进行请求                 |
| cancel       | 无                          | Unit     | 取消请求，注意对于已经完成的请求无法取消   |
| isExecuted   | 无                          | Bool     | 请求是否正在执行中或者已经执行完成      |
| isCanceled   | 无                          | Bool     | 请求是否已取消                |
| clone        | 无                          | Call     | 克隆新的Call对象             |

#### interface CallBack

异步请求的回调处理接口

| 成员函数        | 入参                              | 返回值    | 作用描述   |
|-------------|---------------------------------|--------|--------|
| onFailure   | call: Call,  e: Exception       | Unit   | 异常回调处理 |
| onResponse  | call: Call,  response: Response | Unit   | 正常回调处理 |

#### class Dispatcher

网络请求的执行器，可以定制发起异步请求的策略，以及同时运行异步请求的数量


| 成员函数                   | 入参                                | 返回值      | 作用描述                                                                            |
|------------------------|-----------------------------------|----------|---------------------------------------------------------------------------------|
| init                   | 无                                 | Unit     | 无参构造                                                                            |
| setMaxRequests         | maxRequests: Int64                | Unit     | 设置并发调用Call最大数                                                                   |
| getMaxRequests         | 无                                 | Int64    | 获取并发调用Call最大数                                                                   |
| setIdleCallback        | idleCallback: Option\<()-> Unit\> | Unit     | 设置分发器空闲时的回调函数                                                                   |
| setMaxRequestsPerHost  | maxRequestsPerHost: Int64         | Unit     | 设置同一个hostname的Call最大并发数， 注意这里是对URL解析后的hostname而不是dns解析后的ip 如果不同域名解析成同一个ip这里无法限制 |
| getMaxRequestsPerHost  | 无                                 | Int64    | 获取同一个hostname的Call最大并发数                                                         |
| cancelAll              | 无                                 | Unit     | 消执行所有运行中和预备运行的Call对象                                                            |
| queuedCallsCount       | 无                                 | Int64    | 获取等待运行的Call数量                                                                   |
| runningCallsCount      | 无                                 | Int64    | 获取正在运行中的Call数量                                                                  |

#### interface EventListener

事件监听器

| 成员函数                 | 入参                                                                             | 返回值      | 作用描述             |
|----------------------|--------------------------------------------------------------------------------|----------|------------------|
| callStart            | call: Call                                                                     | Unit     | 监听处理调用Call前      |
| callEnd              | call: Call                                                                     | Unit     | 监听处理调用Call后      |
| dnsStart             | call: Call, domainName: String                                                 | Unit     | 监听处理调用dns解析前     |
| dnsEnd               | call: Call, domainName: String, allRoutes: ArrayList<Route>                    | Unit     | 监听处理调用dns解析后     |
| connectStart         | call: Call, socketAddress: SocketAddress                                       | Unit     | 监听处理socket连接前    |
| connectEnd           | call: Call, socketAddress: SocketAddress, protocol: Protocol                   | Unit     | 监听处理socket连接后    |
| secureConnectStart   | call: Call                                                                     | Unit     | 监听处理tlsSocket连接前 |
| secureConnectEnd     | call: Call, tlsConfig: TlsClientConfig                                         | Unit     | 监听处理tlsSocket连接后 |
| connectFailed        | call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException | Unit     | 监听处理连接失败         |
| requestHeadersStart  | call: Call                                                                     | Unit     | 监听处理发送请求头前       |
| requestHeadersEnd    | call: Call                                                                     | Unit     | 监听处理发送请求头后       |
| requestBodyStart     | call: Call                                                                     | Unit     | 监听处理发送请求体前       |
| requestBodyEnd       | call: Call, byteCount: Int64                                                   | Unit     | 监听处理发送请求体后       |
| requestFailed        | call: Call, e: HttpException                                                   | Unit     | 监听处理请求失败         |
| responseHeadersStart | call: Call                                                                     | Unit     | 监听处理接受响应头前       |
| responseHeadersEnd   | call: Call                                                                     | Unit     | 监听处理接受响应头后       |
| responseBodyStart    | call: Call                                                                     | Unit     | 监听处理接受响应体前       |
| responseBodyEnd      | call: Call, byteCount: Int64                                                   | Unit     | 监听处理接受响应体后       |
| responseFailed       | call: Call, e: HttpException                                                   | Unit     | 监听处理响应失败         |

#### class Request <: ToString

请求对象

| 成员函数            | 入参                          | 返回值                                | 作用描述                           |
|-----------------|-----------------------------|------------------------------------|--------------------------------|
| getUrl          | 无                           | URL                                | 获取URL对象                        |
| getMethod       | 无                           | String                             | 获取请求方法                         |
| getBody         | 无                           | Option\<RequestBody\>              | 获取请求体                          |
| newBuilder      | 无                           | RequestBuilder                     | 根据自身配置创建Builder                |
| getHeaders      | 无                           | Header                             | 获取整个Header头对象                  |
| getHeader       | 无                           | name: String                       | 获取Header中key对应的 Option<String> |
| getHeader       | 无                           | name: String, defaultValue: String | 获取Header中key对应的value,如果没有返回默认值 |
| getCacheControl | 无                           | CacheControl                       | 获取请求中缓存控制对象                    |
| getTag          | s: String                   | Tag                                | 获取标签                           |
| removeTag       | s: String                   | Unit                               | 移除标签                           |

| 静态函数      | 入参    | 返回值              | 作用描述                  |
|-----------|-------|------------------|-----------------------|
| builder   | 无     | RequestBuilder   | 创建 Request 的Builder   |

#### class RequestBuilder

用于创建Request，用户通过链式调用配置其属性

| 成员函数         | 入参                                                                        | 返回值             | 作用描述              |
|--------------|---------------------------------------------------------------------------|-----------------|-------------------|
| url          | url: String                                                               | RequestBuilder  | 根据字符串配置URL        |
| url          | url: URL                                                                  | RequestBuilder  | 重载根据URL配置         |
| header       | name: String, value: String                                               | RequestBuilder  | 添加请求头key-value键值对 |
| method       | method: String, body!: Option\<RequestBody\> = Option\<RequestBody\>.None | RequestBuilder  | 配置请求方法 和请求体       |
| put          | body: RequestBody                                                         | RequestBuilder  | 配置PUT请求方法 和请求体    |
| post         | body: RequestBody                                                         | RequestBuilder  | 配置POST请求方法 和请求体   |
| patch        | body: RequestBody                                                         | RequestBuilder  | 配置PATCH请求方法 和请求体  |
| delete       | body: Option\<RequestBody\>                                               | RequestBuilder  | 配置DELETE请求方法 和请求体 |
| get          | 无                                                                         | RequestBuilder  | 配置GET请求方法         |
| head         | 无                                                                         | RequestBuilder  | 配置HEAD请求方法        |
| build        | Request                                                                   | RequestBuilder  | 创建Request         |
| removeHeader | name: String                                                              | RequestBuilder  | 移除请求头key对应的value  |
| header       | header: Header                                                            | RequestBuilder  | 配置请求头             |
| cacheControl | cacheControl: CacheControl                                                | RequestBuilder  | 配置请求中缓存控制头        |
| tag          | s: String                                                                 | RequestBuilder  | 设置标签              |


#### class Tag

标签

| 成员函数        | 入参                | 返回值 | 作用描述 |
|-------------|-------------------|-----|------|
| init        | tag：String        | 无   | 构造器  |


#### class MediaType <: ToString

媒体类型

| 成员函数         | 入参                       | 返回值       | 作用描述   |
|--------------|--------------------------|-----------|--------|
| getType      | 无                        | String    | 获取主类型  |
| getSubtype   | 无                        | String    | 获取子类型  |
| getCharset   | 无                        | String    | 获取字符集  |


| 静态函数  | 入参               | 返回值                 | 作用描述                         |
|-------|------------------|---------------------|------------------------------|
| get   | string: String   | MediaType           | 解析字符串为MediaType对象，解析失败抛出异常   |
| parse | string: String   | Option\<MediaType\> | 解析字符串为MediaType对象，解析失败返回NONE |

#### interface RequestBody

请求体对象

| 成员函数             | 入参                              | 返回值                 | 作用描述                             |
|------------------|---------------------------------|---------------------|----------------------------------|
| contentType      | 无                               | Option\<MediaType\> | 获取请求体的请求体数据类型                    |
| getContentLength | 无                               | Int64               | 获取请求体的长度                         |
| writeTo          | sink: Sink                      | Unit                | 将请求体内容写入到sink对象中                 |
| get              | 无                               | InputStream         | 获取请求体的输出流                        |

#### class RealRequestBody <: RequestBody

| 静态函数     | 入参                                                     | 返回值          | 作用描述                      |
|----------|--------------------------------------------------------|--------------|---------------------------|
| create   | contentType: Option\<MediaType\>, content: String      | RequestBody  | 创建请求内容为字符串的RequestBody    |
| create   | contentType: Option\<MediaType\>, bytes: Array\<Byte\> | RequestBody  | 创建请求内容为Byte数组的RequestBody |
| create   | contentType: Option\<MediaType\>, file: File           | RequestBody  | 创建请求内容为文件的RequestBody     |


#### class FormBody <: RequestBody 

form表单格式的请求体

| 静态函数      | 入参   | 返回值              | 作用描述                   |
|-----------|------|------------------|------------------------|
| builder   | 无    | FormBodyBuilder  | 创建 FormBody 的Builder   |

#### class FormBodyBuilder <: Builder\<FormBody\> 

| 成员函数  | 入参                           | 返回值             | 作用描述            |
|-------|------------------------------|-----------------|-----------------|
| build | 无                            | FormBody        | 返回构建的FormBody对象 |
| add   | name: String, value: String  | FormBodyBuilder | 添加配置表单的键值对      |

#### class MultipartBody <: RequestBody

多类型格式的请求体

| 静态函数        | 入参   | 返回值                  | 作用描述                      |
|-------------|------|----------------------|---------------------------|
| builder     | 无    | MultipartBodyBuilder | 创建 MultipartBody 的Builder |
| getBoundary | 无    | String               | 获取boundary随机值             |
| getParts    | 无    | ArrayList\<Part\>    | 获取所有添加的Part               |
| getType     | 无    | MediaType            | 获取原始类型                    |

#### class MultipartBodyBuilder <: Builder\<MultipartBody\>

| 成员函数            | 入参                                                | 返回值                  | 作用描述                                                               |
|-----------------|---------------------------------------------------|----------------------|--------------------------------------------------------------------|
| build           | 无                                                 | FormBody             | 返回构建的MultipartBody对象                                               |
| setType         | contentType: MediaType                            | MultipartBodyBuilder | 设置多请求类型，默认为multipart/mixed                                         |
| addPart         | part: Part                                        | MultipartBodyBuilder | 添加一个part                                                           |
| addPart         | body: RequestBody                                 | MultipartBodyBuilder | 根据body创建part对象并添加                                                  |
| addPart         | headers: Header, body: RequestBody                | MultipartBodyBuilder | 根据header, body创建part对象并添加，header不允许使用 Content-Type以及Content-Length |
| addFormDataPart | name: String, value: String                       | MultipartBodyBuilder | 创建表单类型的part并添加                                                     |
| addFormDataPart | name: String, filename: String, body: RequestBody | MultipartBody        | 创建带文件的表单类型的part并添加                                                 |

#### class Part 

| 静态函数            | 入参                                                 | 返回值    | 作用描述                   |
|-----------------|----------------------------------------------------|--------|------------------------|
| create          | headers: Option\<Header\>, body: RequestBody       | Part   | 根据header, body创建part对象 |
| create          | body: RequestBody                                  | Part   | 根据body创建part对象         |
| createFormData  | name: String, value: String                        | Part   | 创建表单类型的part            |
| addFormDataPart | name: String, filename: String, body: RequestBody  | Part   | 创建带文件的表单类型的part        |

#### class Response <: ToString

请求的响应

| 成员函数                   | 入参                                  | 返回值                     | 作用描述                                                                   |
|------------------------|-------------------------------------|-------------------------|------------------------------------------------------------------------|
| newBuilder             | 无                                   | ResponseBuilder         | 根据自身配置创建 Builder                                                       |
| getRequest             | 无                                   | Request                 | 获取对应的 Request 对象                                                       |
| getProtocol            | 无                                   | Protocol                | 获取使用协议                                                                 |
| getCode                | 无                                   | Int64                   | 获取状态码                                                                  |
| getMessage             | 无                                   | String                  | 获取报文消息                                                                 |
| isSuccess              | 无                                   | Bool                    | 请求是否成功                                                                 |
| getHeaders             | 无                                   | Header                  | 获取整个响应头                                                                |
| getHeader              | name: String                        | Option\<String\>        | 获取Header中key对应的value                                                   |
| getHeader              | name: String, defaultValue: String  | String                  | 获取Header中key对应的value,如果没有返回默认值                                         |
| getBody                | 无                                   | Option\<ResponseBody\>  | 获取响应体                                                                  |
| getPrevResponse        | 无                                   | Option\<Response\>      | 获取重定向的前置响应对象                                                           |
| isRedirect             | 无                                   | Bool                    | 是否是重定向响应                                                               |
| close                  | 无                                   | Unit                    | 关闭响应体资源                                                                |
| toString               | 无                                   | String                  | 格式化输出                                                                  |
| getCacheControl        | 无                                   | CacheControl            | 获取缓存控制对象                                                               |
| getSentRequestAtMillis | 无                                   | Int64                   | 获取请求发送时间                                                               |
| getSentRequestAtMillis | 无                                   | Int64                   | 获取响应方接受时间                                                              |
| getNetworkResponse     | 无                                   | Option<Response>        | 获取网络响应，使用缓存时为None,对于条件请求networkResponse以及cacheResponse可能均不为None        |
| getCacheResponse       | 无                                   | Option<Response>        | 获取缓存中读取的响应，使用网络请求时为None, 对于条件请求networkResponse以及cacheResponse可能均不为None |

| 静态函数     | 入参   | 返回值               | 作用描述                  |
|----------|------|-------------------|-----------------------|
| builder  | 无    | ResponseBuilder   | 创建 Response 的Builder  |

#### class ResponseBody <: Resource

响应体

| 成员函数             | 入参                                                        | 返回值                 | 作用描述        |
|------------------|-----------------------------------------------------------|---------------------|-------------|
| init             | contentType: String, contentLength: Int64, source: Source | 无                   | 构造器         |
| getSource        | 无                                                         | Source              | 获取响应体source |
| close            | 无                                                         | Unit                | 关闭响应体资源     |
| isClosed         | 无                                                         | Unit                | 响应体资源是否已关闭  |
| getContentLength | 无                                                         | Int64               | 获取响应体长度     |
| getContentType   | 无                                                         | Option\<MediaType\> | 获取响应体类型     |
| getString        | 无                                                         | String              | 解析响应体为字符串   |

#### class ResponseBuilder

用于创建Response，通过链式调用配置其属性

| 成员函数                     | 入参                                | 返回值                 | 作用描述                                                  |
|--------------------------|-----------------------------------|---------------------|-------------------------------------------------------|
| build                    | 无                                 | Response            | 通过配置项创建出核心类 Response                                  |
| request                  | request: Request                  | ResponseBuilder     | 配置原请求对象                                               |
| protocol                 | protocol: Protocol                | ResponseBuilder     | 配置http协议                                              |
| code                     | code: Int64                       | ResponseBuilder     | 配置状态码                                                 |
| message                  | message: String                   | ResponseBuilder     | 配置状态信息                                                |
| header                   | name: String, value: String       | ResponseBuilder     | 重设响应头key-value键值对                                     |
| addHeader                | name: String, value: String       | ResponseBuilder     | 添加响应头key-value键值对                                     |
| removeHeader             | name: String                      | ResponseBuilder     | 移除响应头key-value键值对                                     |
| prevResponse             | prevResponse: Option\<Response\>  | ResponseBuilder     | 配置重定向的前置响应对象。注意，如果参数不为None的话，如果响应对象的 body 不为 None，抛异常 |
| body                     | body: ResponseBody                | ResponseBuilder     | 配置响应体                                                 |
| header                   | header: Header                    | ResponseBuilder     | 配置响应头                                                 |
| sentRequestAtMillis      | sentRequestAtMillis: Int64        | ResponseBuilder     | 配置请求发送时间                                              |
| receivedResponseAtMillis | receivedResponseAtMillis: Int64   | ResponseBuilder     | 配置响应接受时间                                              |
| networkResponse          | cacheResponse: Option<Response>   | ResponseBuilder     | 配置网络响应                                                |
| cacheResponse            | networkResponse: Option<Response> | ResponseBuilder     | 配置缓存中读取的响应                                            |


#### interface Source <: Resource

| 成员函数        | 入参                                         | 返回值   | 作用描述        |
|-------------|--------------------------------------------|-------|-------------|
| read        | bytes: ByteArrayStream, byteCount: Int64   | Int64 | 读取指定字节的数据   |
| close       | 无                                          | Unit  | 关闭source    |
| isClosed    | 无                                          | Unit  | source是否已关闭 |


#### class OkBuffer <: Source

用于读取响应报文以及缓存数据的功能类

| 成员函数               | 入参                                | 返回值     | 作用描述                            |
|--------------------|-----------------------------------|---------|---------------------------------|
| init               | inputStream: InputStream          | 无       | 构造器 inputStream: 处理的输入流         |
| readUtf8LineStrict | 无                                 | String  | 按\\r\\n读取utf8字符串                |
| readUtf8LineStrict | limit: Int64                      | String  | 按\\r\\n读取utf8字符串                |
| readUtf8Line       | 无                                 | String  | 按\n读取utf8字符串                    |
| readUtf8Line       | limit: Int64                      | String  | 按\n读取utf8字符串                    |
| skipBuffer         | limit: Int64                      | Unit    | 忽略并跳过limit个Byte                 |
| readByte           | 无                                 | Byte    | 读取一个Byte                        |
| indexOf            | b: Byte, start: Int64, end: Int64 | Int64   | 从start到end的位置找b的偏移位置并读取数据到缓冲    |


#### class OkGzipSource <: Source

解压缩gzip数据源

| 成员函数    | 入参              | 返回值      | 作用描述        |
|---------|-----------------|----------|-------------|
| init    | source: Source  | 无        | source： 数据源 |


#### interface Sink

| 成员函数  | 入参                   | 返回值  | 作用描述                                 |
|-------|----------------------|------|--------------------------------------|
| write | bytes: Array\<Byte\> | Unit | 将buffer写入到sink中                      |
| flush | 无                    | Unit | 将数据从缓存中刷入流中                          |
| close | 无                    | Unit | 关闭sink                               |


#### RealBufferSink <: Sink

缓存流，将write数据缓存, 调用flush时刷入, 如果没有显式调用flush，则在close时刷入数据

| 成员函数 | 入参         | 返回值 | 作用描述 |
|------|------------|-----|------|
| init | sink: Sink | 无   | 构造器  |


#### class Chain

拦截器链

| 成员函数             | 入参                                                                        | 返回值                  | 作用描述             |
|------------------|---------------------------------------------------------------------------|----------------------|------------------|
| getTransmitter   | 无                                                                         | Transmitter          | 获取Transmitter对象  |
| getRequest       | 无                                                                         | Request              | 获取请求对象           |
| getExchange      | 无                                                                         | Exchange             | 获取Exchange对象     |
| proceed          | request: Request                                                          | Response             | 执行拦截器            |
| proceed          | request: Request,  transmitter: Transmitter, exchange: Option\<Exchange\> | Request              | 执行拦截器重载          |
| getCall          | 无                                                                         | Call                 | 获取Call对象         |
| getConnection    | 无                                                                         | Option\<Connection\> | 获取连接对象           |

#### interface Interceptor

默认添加拦截器按顺序有

1. RetryAndFollowUpInterceptor (负责 HTTP 请求的重定向功能，和重试机制)
2. BridgeInterceptor(负责桥接功能，把用户所构建的请求转换为真正的 Request，将服务器所返回的响应转换为用户所能够使用的 Response)
3. ConnectInterceptor(主要负责的是与服务器的连接的建立)
4. CallServerInterceptor(它真正实现了对服务器连接的读取)

| 成员函数         | 入参               | 返回值       | 作用描述   |
|--------------|------------------|-----------|--------|
| intercept    | chain: Chain     | Response  | 拦截处理请求 |

#### class Route <: Hashable & Equatable\<Route\>

连接服务器的路由

| 成员函数                 | 入参                                                  | 返回值           | 作用描述                                                                     |
|----------------------|-----------------------------------------------------|---------------|--------------------------------------------------------------------------|
| init                 | address: Address, inetSocketAddress: SocketAddress  | 无             | address  包含服务器地址和连接协议的对象， inetSocketAddress 标准库SocketAddress类型表示socket地址 |
| getAddress           | 无                                                   | Address       | 获取 Address 对象                                                            |
| getInetSocketAddress | 无                                                   | SocketAddress | 获取 SocketAddress 对象                                                      |


#### class Address <: Hashable & Equatable\<Route\>

包含服务器地址和连接协议的对象

| 成员函数         | 入参                                         | 返回值                 | 作用描述                           |
|--------------|--------------------------------------------|---------------------|--------------------------------|
| init         | url: URL, protocols: ArrayList\<String\>   | 无                   | url  服务器URL资源， protocols 请求协议  |
| getUrl       | 无                                          | URL                 | 获取 URL 对象                      |
| getProtocols | 无                                          | ArrayList\<String\> | 获取协议                           |


#### enum protocol <: ToString

| HTTP_1_0| HTTP_1_1|  HTTP_2 | H2_PRIOR_KNOWLEDGE

| 成员函数       | 入参   | 返回值     | 作用描述    |
|------------|------|---------|---------|
| toString   | 无    | String  | 获取协议字符串 |

| 静态函数      | 入参                 | 返回值       | 作用描述             |
|-----------|--------------------|-----------|------------------|
| get       | protocol: String   | Protocol  | 字符串转protocol对象   |


#### class Transmitter

传输层的连接流的抽象

| 成员函数                       | 入参                                 | 返回值    | 作用描述                               |
|----------------------------|------------------------------------|--------|------------------------------------|
| init                       | client: OkHttpClient, call: Call   | 无      | client 客户端配置对象, call 请求的增强         |
| cancel                     | 无                                  | Unit   | 关闭socket                           |
| isCanceled                 | 无                                  | Unit   | 是否已经关闭                             |
| prepareToConnect           | request: Request                   | Unit   | 进行准备连接前必要的初始化 如果已经进行过连接，可以复用则不再初始化 |
| hasConnection              | 无                                  | Bool   | 是否已经建立连接                           |
| hasExchange                | 无                                  | Bool   | 是否已经建立传输通道                         |
| exchangeDoneDueToException | 无                                  | Unit   | 关闭传输通道                             |
| noMoreExchanges            | 无                                  | Unit   | 由于异常关闭传输通道并取消连接                    |
| canRetry                   | 无                                  | Bool   | 是否可以重试                             |


#### interface ExchangeCodec

对不同协议解析逻辑的封装

| 成员函数                   | 入参                   | 返回值                       | 作用描述                         |
|------------------------|----------------------|---------------------------|------------------------------|
| readResponseHeaders    | expectContinue: Bool | Option\<ResponseBuilder\> | 读取请求头                        |
| reportedContentLength  | response: Response   | Int64                     | 解析请求体长度                      |
| openResponseBodySource | response: Response   | Source                    | 创建用于输出响应体的source对象           |
| getConnection          | 无                    | Connection                | 获取连接对象                       |
| writeRequestHeaders    | request: Request     | Unit                      | 写入请求头报文                      |
| finishRequest          | 无                    | Int64                     | 将请求从缓存中刷入套接字并且结束请求标记不再进行新的传输 |
| createRequestBody      | request: Request     | Sink                      | 创建写入请求体的sink                 |
| flushRequest           | 无                    | Unit                      | 将请求从缓存中刷入套接字                 |
| getTrailers            | 无                    | Header                    | 获取尾部Header                   |
| cancel                 | 无                    | Unit                      | 关闭socket                     |

#### class Exchange

一次完整的http请求的传输的抽象对象

| 成员函数                       | 入参                                                                                  | 返回值                        | 作用描述                         |
|----------------------------|-------------------------------------------------------------------------------------|----------------------------|------------------------------|
| init                       | transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec  | 无                          | 构造器                          |
| readResponseHeaders        | expectContinue: Bool                                                                | Option\<ResponseBuilder\>  | 读取请求头                        |
| openResponseBody           | response: Response                                                                  | ResponseBody               | 解析并创建响应体                     |
| getConnection              | 无                                                                                   | Connection                 | 获取连接                         |
| cancel                     | 无                                                                                   | Bool                       | 关闭通道                         |
| detachWithViolence         | 无                                                                                   | Unit                       | 暴力关闭当前数据通道，会导致该通道依赖的流也无法使用   |
| noNewExchangesOnConnection | 无                                                                                   | Bool                       | 标记为此传输通道不再可用                 |
| noRequestBody              | 无                                                                                   | Unit                       | 无请求体发送报文                     |
| getTrailers                | 无                                                                                   | Header                     | 获取尾部Header                   |
| createRequestBody          | request: Request                                                                    | Sink                       | 创建写入请求体的sink                 |
| writeRequestHeaders        | request: Request                                                                    | Unit                       | 写入请求头报文                      |
| flushRequest               | 无                                                                                   | Unit                       | 将请求从缓存中刷入套接字                 |
| finishRequest              | 无                                                                                   | Unit                       | 将请求从缓存中刷入套接字并且结束请求标记不再进行新的传输 |

#### class Http1ExchangeCodec <: ExchangeCodec

处理Http1协议解析逻辑

| 成员函数   | 入参                                                                                              | 返回值       | 作用描述                |
|--------|-------------------------------------------------------------------------------------------------|-----------|---------------------|
| init   | client: OkHttpClient, realConnection: Connection, source: OkBuffer, sink: BufferedOutputStream  | 无         | 构造器                 |

#### class Http2ExchangeCodec <: ExchangeCodec

处理Http2协议解析逻辑

| 成员函数 | 入参                                                                                 | 返回值         | 作用描述                |
|------|------------------------------------------------------------------------------------|-------------|---------------------|
| init | client: OkHttpClient, realConnection: Connection, http2Connection: H2Connection    | 无           | 构造器                 |


| 静态函数                 | 入参                                      | 返回值              | 作用描述                                            |
|----------------------|-----------------------------------------|------------------|-------------------------------------------------|
| readHttp2HeadersList | headerBlock: Header, protocol: Protocol | ResponseBuilder  | Http2 的 Header 转换为标准Header并以ResponseBuilder形式返回 |

#### class Connection

socket 以及 http1连接
 
| 成员函数            | 入参                                                                                                                                                                             | 返回值                      | 作用描述                                  |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|---------------------------------------|
| init            | connectionPool: ConnectionPool, route: Route                                                                                                                                   | 无                        | 构造器  connectionPool 连接池对象， route 路由对象 |
| getProtocol     | 无                                                                                                                                                                              | Protocol                 | 获取协议                                  |
| getTransmitters | 无                                                                                                                                                                              | ArrayList\<Transmitter\> | 获取该连接关联的所有Transmitter实例               |
| noExchanges     | 无                                                                                                                                                                              | Unit                     | 标记该连接上不再创建新的传输                        |
| getSocket       | 无                                                                                                                                                                              | Option\<OKSocket\>       | 获取socket                              |
| getRoute        | 无                                                                                                                                                                              | Route                    | 获取路由对象                                |
| isHealthy       | 无                                                                                                                                                                              | Bool                     | 连接是否健康可用                              |
| isMultiplexed   | 无                                                                                                                                                                              | Bool                     | 连接是否支持多路复用                            |
| onSettings      | h2: H2Connection                                                                                                                                                               | Bool                     | 设置h2连接创建最大的流                          |
| connect         | connectTimeout: Option\<Duration\>, readTimeout: Option\<Duration\>, writeTimeout: Option\<Duration\>, connectionRetryEnabled: Bool, eventListener: EventListener, call: Call) | Unit                     | 开始连接                                  |
| cancel          | 无                                                                                                                                                                              | Unit                     | 关闭socket                              |

#### class H2Connection

http2连接

| 成员函数                    | 入参                                                                                                                                | 返回值      | 作用描述                                                    |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------|----------|---------------------------------------------------------|
| init                    | socket: SocketClient, sink: BufferedOutputStream, source: OkBuffer,  listener !: Option\<Connection\> = Option\<Connection\>.None | 无        | 构造器                                                     |
| start                   | 无                                                                                                                                 | Unit     | 作用为启动连接, 初始化设置,发送初始帧并开启读取子线程， 对象创建后需要优先调用，否则在后续使用出现未知问题 |
| openStreamCount         | 无                                                                                                                                 | Int64    | 获取在该连接开启的的可用Stream流数量                                   |
| close                   | 无                                                                                                                                 | Unit     | 关闭连接, 并移除stream                                         |
| writeData               | streamId: UInt32, outFinished: Bool, buffer: ByteArrayStream, length: Int64                                                       | Unit     | 发送 data 帧, outFinished: 是否是endStream 帧                  |
| isHealthy               | 无                                                                                                                                 | Bool     | 连接是否健康                                                  |
| shutdownConn            | statusCode: ErrorCode                                                                                                             | Unit     | 发送GOAway帧,准备关闭连接                                        |
| setSettings             | settings: Settings                                                                                                                | Unit     | 覆盖设置并发送Settings帧                                        |
| newStream               | request: Request                                                                                                                  | H2Stream | 创建H2Stream对象                                            |
| getMaxConcurrentStreams | 无                                                                                                                                 | Int64    | 可创建Stream数最大值                                           |
| flush                   | 无                                                                                                                                 | Int64    | 刷入writer的缓存                                             |

#### class Settings

http2 连接 settings帧 配置项
id对象配置项常量为
HEADER_TABLE_SIZE = 1 (报头表的最大字节数)
ENABLE_PUSH = 2 (服务器推送)
MAX_CONCURRENT_STREAMS = 4 (最大创建流数)
MAX_FRAME_SIZE = 5 (单帧负载最大字节值)
MAX_HEADER_LIST_SIZE = 6 (报头集合的最大字节数)
INITIAL_WINDOW_SIZE = 7 (连接初始的流量窗口字节数)

| 成员函数                    | 入参                      | 返回值       | 作用描述                |
|-------------------------|-------------------------|-----------|---------------------|
| setting                 | id: Int64, value: Int64 | Settings  | 设置配置项参数             |
| isSet                   | id: Int64               | Bool      | 该id是否进行了配置          |
| get                     | id: Int64               | Int64     | 获取该id配置的值           |
| size                    | 无                       | Int64     | 已配置项参数的数量           |
| getHeaderTableSize      | 无                       | Int64     | 获取id为1的配置参数         |
| getMaxConcurrentStreams | 无                       | Int64     | 获取id为4的配置参数         |
| getMaxFrameSize         | 无                       | Int64     | 获取id为5的配置参数         |
| getInitialWindowSize    | 无                       | Int64     | 获取id为7的配置参数         |
| merge                   | other: Settings         | Unit      | 用新的settings对象合并覆盖自身 |

#### class H2Stream

http2流

| 成员函数            | 入参                                               | 返回值                 | 作用描述                              |
|-----------------|--------------------------------------------------|---------------------|-----------------------------------|
| getSink         | 无                                                | Sink                | 获取关联sink                          |
| getSource       | 无                                                | Source              | 获取关联Source                        |
| getId           | 无                                                | UInt32              | 获取StreamId                        |
| getErrorCode    | 无                                                | Option\<ErrorCode\> | 获取错误code                          |
| close           | rstStatusCode: ErrorCode, errorException: String | Unit                | 发送Reset_Stream帧并从连接中移除stream      |
| closeLater      | rstStatusCode: ErrorCode                         | Bool                | 开启子线程发送Reset_Stream帧并从连接中移除stream |
| getConnection   | 无                                                | H2Connection        | 获取H2连接对象                          |
| takeHeaders     | 无                                                | Header              | 阻塞线程直到获取响应的Header                 |
| enqueueTrailers | trailers: Header                                 | Unit                | Data帧中添加尾部的Header                 |
| getTrailers     | 无                                                | Header              | 获取响应的尾部Header                     |
| isOpen          | 无                                                | Bool                | stream是否开启中                       |

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
| 成员函数        | 入参                  | 返回值                 | 作用描述                          |
|-------------|---------------------|---------------------|-------------------------------|
| getCode     | 无                   | Int64               | 获取errorCode id                |
| toString    | 无                   | String              | 获取errorCode 字符串               |

| 静态函数         | 入参                    | 返回值                   | 作用描述                           |
|--------------|-----------------------|-----------------------|--------------------------------|
| fromHttp2    | errorCodeInt: Int64   | Option\<ErrorCode\>   | 根据errorCode id 获取errorCode 对象  |

#### class OKSocket <: Resource & InputStream & OutputStream

包装了SocketClient,用于支持socket被缓冲流包装时仍然具备使用读写超时的能力

| 成员函数       | 入参                                                                                        | 返回值             | 作用描述                                |
|------------|-------------------------------------------------------------------------------------------|-----------------|-------------------------------------|
| init       | client: SocketClient, readTimeOut: Option\<Duration\>, writeTimeOut: Option\<Duration\>   | 无               | 构造器                                 |

#### enum SocketClient <: Resource 

封装 TlsSocket 和 Socket 便于提供统一接口

| 成员函数      | 入参                                        | 返回值   | 作用描述                                                                    |
|-----------|-------------------------------------------|-------|-------------------------------------------------------------------------|
| connect   | 无                                         | Unit  | 进行socket连接                                                              |
| connect   | timeout: Duration                         | Unit  | 在指定时间内进行socket的连接,超时抛出SocketTimeoutException异常                          |
| read      | buffer: Array\<Byte\>                     | Int64 | 从已建立的 Socket 连接中读取数据，存放到入参 buffer 中                                     |
| read      | buffer: Array\<Byte\> , timeout: Duration | Int64 | 在指定时间内从已建立的 Socket 连接中读取数据，存放到入参 buffer 中, 超时抛出SocketTimeoutException异常 |
| write     | buffer: Array<Byte>                       | Unit  | 将入参 buffer 中存储的数据写入到 Socket 连接中                                         |
| write     | buffer: Array<Byte> , timeout: Duration   | Unit  | 在指定时间内将入参 buffer 中存储的数据写入到 Socket 连接中 , 超时抛出SocketTimeoutException异常    |


#### class ConnectionPool

连接池

| 成员函数                | 入参                                                                                    | 返回值    | 作用描述                                                                     |
|---------------------|---------------------------------------------------------------------------------------|--------|--------------------------------------------------------------------------|
| init                | maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute(5)   | 无      | maxIdleConnections 最大空闲连接数, 默认为5 keepAliveDurationNs 连接最大空闲保持存活时间 默认为5分钟 |
| idleConnectionCount | 无                                                                                     | Int64  | 获取当前空闲连接数                                                                |
| evictAll            | 无                                                                                     | Unit   | 移除并关闭所有空闲连接                                                              |
| connectFailed       | failedRoute: Route                                                                    | Unit   | 记录连接失败的路由                                                                |

#### class StatusLine <: ToString

解析报文第一行StatusLine

| 成员函数     | 入参                                                 | 返回值   | 作用描述        |
|----------|----------------------------------------------------|-------|-------------|
| init     | protocol: Protocol, code: Int64, message: String   | 无     | 构造器         |

| 静态函数       | 入参                   | 返回值          | 作用描述                           |
|------------|----------------------|--------------|--------------------------------|
| parse      | statusLine: String   | StatusLine   | 解析字符串为StatusLine, 如果格式不正确则抛出异常 |

#### class CookieUtil

解析cookie

| 静态函数       | 入参                                | 返回值                 | 作用描述                   |
|------------|-----------------------------------|---------------------|------------------------|
| parseAll   | url: URL, headers: Header         | ArrayList\<Cookie\> | 解析所有cookie             |
| parse      | url: URL, setCookie: String       | Option\<Cookie\>    | 解析单个cookie,如果不合法返回None |

#### interface CookieJar 

| 成员函数               | 入参                                 | 返回值             | 作用描述                |
|--------------------|------------------------------------|-----------------|---------------------|
| saveFromResponse   | url: URL, cookies: Array\<Cookie\> | Unit            | 保存cookie            |
| loadForRequest     | url: URL                           | Array\<Cookie\> | 从CookieJar中获取cookie |


#### class Cache <: Resource

处理http缓存功能

| 成员函数         | 入参                                      | 返回值                | 作用描述                                         |
|--------------|-----------------------------------------|--------------------|----------------------------------------------|
| init         | directoryPath: String, maxSize: Int64   | 无                  | directoryPath: 缓存目录地址, maxSize: 缓存大小，单位byte  |
| getDirectory | 无                                       | Directory          | 获取缓存目录                                       |
| getMaxSize   | 无                                       | Int64              | 获取最大可用缓存值                                    |
| evictAll     | 无                                       | Unit               | 去除所有缓存内存以及缓存文件(不包括journal)                   |
| delete       | 无                                       | Directory          | 删除缓存文件以及journal,但不删除内存中缓存                    |
| urls         | 无                                       | Iterator<String>   | 获取已缓存url的迭代器                                 |
| flush        | 无                                       | Unit               | 刷新缓存流到缓存文件中                                  |
| initialize   | 无                                       | Unit               | 初始化，如过有读取缓存文件则读取保存于内存中，没有则构建缓存文件             |


| 静态函数    | 入参        | 返回值      | 作用描述                    |
|---------|-----------|----------|-------------------------|
| key     | url: URL  | String   | 根据url进行md5加密，用于缓存文件的文件名 |

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
+ no-transform
+ must-revalidate
+ max-age = [秒]
+ s-maxage = [秒]

| 成员函数            | 入参                                      | 返回值           | 作用描述                                        |
|-----------------|-----------------------------------------|---------------|---------------------------------------------|
| init            | directoryPath: String, maxSize: Int64   | 无             | directoryPath: 缓存目录地址, maxSize: 缓存大小，单位byte |
| noCache         | 无                                       | Bool          | 是否使用缓存                                      |
| noStore         | 无                                       | Bool          | 是否不保存缓存或请求                                  |
| maxAgeSeconds   | 无                                       | Int64         | 缓存的最大Age值，单位：秒                              |
| maxStaleSeconds | 无                                       | Int64         | 已过期缓存的最大Age值，单位：秒                           |
| sMaxAgeSeconds  | 无                                       | Int64         | 公共缓存的最大Age值，单位：秒                            |
| minFreshSeconds | 无                                       | Int64         |  期望指定时间内的响应，单位：秒                            |
| isPrivate       | 无                                       | Bool          | 是否私有缓存                                      |
| isPublic        | 无                                       | Bool          | 是否公共缓存                                      |
| mustRevalidate  | 无                                       | Bool          | 过期缓存必须再次校验                                  |
| onlyIfCached    | 无                                       | Int64         | 只使用缓存                                       |
| noTransform     | 无                                       | Bool          | 不允许更改请求或响应                                  |
| immutable       | 无                                       | Bool          | 资源保持不变                                      |
| minFreshSeconds | 无                                       | Int64         | 期望指定时间内的响应                                  |
| onlyIfCached    | 无                                       | Int64         | 只使用缓存                                       |

| 静态函数    | 入参   | 返回值                 | 作用描述                                        |
|---------|------|---------------------|---------------------------------------------|
| builder | 无    | CacheControlBuilder | 创建 CacheControl 的Builder                    |
| parse   | 无    | header: Header      | 从Header中解析Cache-control头的值并返回CacheControl对象 |

#### class CacheControlBuilder

用于创建客户端缓存控制

| 成员函数           | 入参          | 返回值                  | 作用描述                                        |
|----------------|-------------|----------------------|---------------------------------------------|
| noCache        | 无           | CacheControlBuilder  | 配置是否使用缓存                                    |
| noStore        | 无           | CacheControlBuilder  | 是否不保存缓存或请求                                  |
| maxAge         | Int64       | CacheControlBuilder  | 配置使用缓存的最大Age值，单位：秒                          |
| maxStale       | Int64       | CacheControlBuilder  | 配置使用已过期缓存的最大Age值，单位：秒                       |
| minFresh       | Int64       | CacheControlBuilder  | 配置期望指定时间内的缓存，单位：秒                           |
| onlyIfCached   | 无           | CacheControlBuilder  | 配置只使用缓存                                     |
| noTransform    | 无           | CacheControlBuilder  | 配置不允许更改请求                                   |
| immutable      | 无           | CacheControlBuilder  | 配置资源保持不变                                    |
| build          | 无           | CacheControlBuilder  | 创建CacheControl对象                            |

#### 全局函数

| 全局函数                 | 入参       | 返回值           | 作用描述                                   |
|----------------------|----------|---------------|----------------------------------------|
| getSimpleCookieJar   | 无        | CookieJar     | 获取简单的使用内存的cookieJar, cookie保存于内存中,无持久化 |

### 5.2 展示示例

#### 同步请求

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

#### 异步请求
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
#### chunked分块传输请求
```

from okhttp import okhttp.*
from std import collection.*
from net import http.*
from std import io.*
from std import socket.*

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("POST", body: MyRequestBody())
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.toString())
    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
        return 0
    }
}

func serve(){
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        println(String.fromUtf8(req.readToEnd()))
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}


class MyRequestBody <:RequestBody {
    public func contentType(): String {
        return "application/json"
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

运行结果
```
helloworld
Response{protocol=http/1.1, code=200, message=OK, url=http://127.0.0.1:38621/1234}
```




