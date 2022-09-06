# 三方库设计说明

## 1 需求场景分析

处理网络请求的轻量级框架，可以有效地执行HTTP返回响应。

## 2 三方库对外提供的特性

1. 支持同步和异步请求
2. 支持http1.1 和 http2 协议
3. 支持连接复用
4. 使用连接池减少请求延迟

## 3 License分析

apache 2.0 License


## 4 依赖分析

依赖仓颉标准库 time ，collection， http，socket， tls， io
三方库 http2


## 5 接口设计

### 5.1 api接口

#### Interface Builder

建造者模式，用于创建可链式调用配置项的配置类，最终创建出核心类。

| 成员函数 | 入参 | 返回值 |    作用描述    |
| -------- | ---- | ------ | -------------- |
| build    | 无   | T      | 创建出核心类。 |


####  class okhttpClient

Call的工厂类，可用于发送 HTTP 请求并读取其响应，外观形式上等同于http客户端，每个客户端都拥有自己的连接池和线程池。重用连接可减少延迟并节省内存。

|           成员函数           |       入参        |         返回值          |         作用描述          |
| --------------------------- | ---------------- | ---------------------- | ------------------------- |
| newCall                     | request: Request | Call                   | 增强请求对象               |
| getFollowRedirects          | 无                | Bool                   | 请求是否允许重定向         |
| getRetryOnConnectionFailure | 无                | Bool                   | 连接失败是否允许重试       |
| getConnectionPool           | 无                | Option<ConnectionPool> | 获取客户端使用的连接池对象 |
| getDispatcher               | 无                | Dispatcher             | 获取客户端分发器          |
| getInterceptors()           | 无                | ArrayList<Interceptor> | 获取自定义连接前处理拦截器 |
| getNetworkInterceptors      | 无                | getNetworkInterceptors | 获取自定义连接后处理拦截器 |
| getCookieJar                | 无                | CookieJar              | 获取CookieJar             |
| getConnectTimeout           | 无                | Option<Duration>       | 获取连接超时时间           |
| getReadTimeout              | 无                | Option<Duration>       | 获取读取连接超时时间       |
| getWriteTimeout()           | 无                | Option<Duration>       | 获取写连接超时时间         |
| getProtocols                | 无                | ArrayList<String       | 获取使用的http协议         |

| 静态函数 | 入参 |        返回值        |         作用描述          |
| -------- | ---- | ------------------- | --------------------------- |
| builder  | 无   | OkHttpClientBuilder | 创建 OkHttpClient 的Builder |


#### class okhttpClientBuilder

用于创建okhttpClient，用户通过链式调用配置其属性

|        成员函数         |                入参                |       返回值       |                                            作用描述                                             |
| --------------------- | ---------------------------------- | ----------------- | --------------------------------------------------------------------------------------------- |
| init                   | 无                                 | 无                | 无参构造                                                                                        |
| build                  | 无                                 | OkHttpClient        | 通过配置项创建出核心类 OkHttpClient                                                                 |
| dispatcher              | dispatcher: Dispatcher               | OkHttpClientBuilder | 配置个性化的请求分发器                                                                             |
| followRedirects         | followRedirects: Bool                | OkHttpClientBuilder | 配置是否允许重定向, 默认为true                                                                      |
| retryOnConnectionFailure | retryOnConnectionFailure: Bool        | OkHttpClientBuilder | 配置连接失败是否允许重试,默认为true                                                                  |
| connectionPool          | connectionPool: Option<ConnectionPool> | OkHttpClientBuilder | 配置客户端使用个性化的连接池对象 ，默认最大空闲数为5，最大空闲时间为5分钟                                   |
| addInterceptor          | interceptor: Interceptor              | OkHttpClientBuilder | 添加用户自定义的连接前处理的拦截器                                                                   |
| addNetworkInterceptor    | interceptor: Interceptor              | OkHttpClientBuilder | 添加用户自定义的连接后处理的拦截器                                                                   |
| connectTimeout          | connectTimeout: Duration               | OkHttpClientBuilder | 配置连接超时时间                                                                                 |
| readTimeout             | readTimeout: Duration                | OkHttpClientBuilder | 配置读取连接超时时间                                                                              |
| writeTimeout            | writeTimeout: Duration               | OkHttpClientBuilder | 配置读取连接超时时间                                                                              |
| protocols               | protocols: ArrayList<String>          | OkHttpClientBuilder | 参数 protocols 使用协议的集合, 目前版本只支持 http/1.1, 强制使用http1.1 以及 h2_prior_knowledge, 强制使用http2 |


#### interface Call

对已准备好执行的请求进行增强行后再执行，已经请求完成过一次的 call 无法再次执行

|  成员函数   |           入参           |  返回值   |              作用描述              |
| --------- | ----------------------- | ------- | --------------------------------- |
| getRequest | 无                       | Request  | 获取封装的请求对象                   |
| execute    | 无                       | Response | 同步进行请求                        |
| enqueue    | responseCallback: Callback | Unit     | 异步进行请求                        |
| cancel     | 无                       | String   | 取消请求，注意对于已经完成的请求无法取消 |
| isExecuted | 无                       | Bool     | 请求是否正在执行中或者已经执行完成      |
| isCanceled | 无                       | Bool     | 请求是否已取消                       |
| clone      | 无                       | Call     | 克隆新的Call对象                     |

#### class Dispatcher

网络请求的执行器，可以定制发起异步请求的策略，以及同时运行异步请求的数量


|       成员函数       |             入参             | 返回值 |                                                  作用描述                                                  |
| ------------------- | ---------------------------- | ----- | --------------------------------------------------------------------------------------------------------- |
| init                | 无                           | Unit   | 无参构造                                                                                                   |
| setMaxRequests        | maxRequests: Int64             | Unit   | 设置并发调用Call最大数                                                                                        |
| getMaxRequests        | 无                           | Int64  | 获取并发调用Call最大数                                                                                        |
| setIdleCallback       | idleCallback: Option<()-> Unit> | Unit   | 设置分发器空闲时的回调函数                                                                                     |
| setMaxRequestsPerHost | maxRequestsPerHost: Int64       | Unit   | 设置同一个hostname的Call最大并发数， 注意这里是对URL解析后的hostname而不是dns解析后的ip 如果不同域名解析成同一个ip这里无法限制 |
| getMaxRequestsPerHost | 无                           | Int64  | 获取同一个hostname的Call最大并发数                                                                             |
| cancelAll            | 无                           | Unit   | 消执行所有运行中和预备运行的Call对象                                                                            |
| queuedCallsCount      | 无                           | Int64  | 获取等待运行的Call数量                                                                                        |
| runningCallsCount     | 无                           | Int64  | 获取正在运行中的Call数量                                                                                      |


#### class Request

请求对象

|    成员函数     | 入参 |             返回值              |                作用描述                 |
| -------------- | ---- | ------------------------------ | -------------------------------------- |
| getUrl         | 无   | URL                             | 获取URL对象                              |
| getMethod       | 无   | String                          | 获取请求方法                             |
| getBody        | 无   | Option<RequestBody>               | 获取请求体                               |
| newBuilder      | 无   | RequestBuilder                   | 根据自身配置创建Builder                    |
| getHeaders      | 无   | Header                          | 获取整个Header头对象                      |
| getHeader       | 无   | name: String                     | 获取Header中key对应的 Option<String>        |
| getHeader       | 无   | name: String, defaultValue: String | 获取Header中key对应的value,如果没有返回默认值 |
| toHttpRequest   | 无   | http.Request                     | 转换成仓颉http库对应的Request对象           |
| getCacheControl | 无   | Option<CacheControl>              | 获取请求中缓存控制对象                     |


| 静态函数 | 入参 |     返回值     |       作用描述        |
| -------- | ---- | ------------- | ------------------- |
| builder  | 无   | RequestBuilder | 创建 Request 的Builder |

#### class RequestBuilder

用于创建Request，用户通过链式调用配置其属性

|   成员函数   |           入参            |     返回值     |             作用描述             |
| ----------- | ------------------------ | ------------- | ------------------------------- |
| url         | url: String               | RequestBuilder | 根据字符串配置URL                  |
| url         | url: URL                  | RequestBuilder | 重载根据URL配置                   |
| header       | name: String, value: String | RequestBuilder | 添加请求头key-value键值对           |
| method       | method: String             | RequestBuilder | 配置请求方法                      |
| body        | requestBody: RequestBody    | RequestBuilder | 配置请求体                        |
| build        | Request                   | RequestBuilder | 创建Request                      |
| removeHeader | name: String               | RequestBuilder | 移除请求头key对应的value            |
| header       | header: Header             | RequestBuilder | 配置请求头                        |
| cacheControl | cacheControl: CacheControl  | RequestBuilder | 配置请求中缓存控制头（830功能未实现） |

#### class RequestBody

请求体对象

|   成员函数    |              入参               |   返回值    |                  作用描述                   |
| ------------ | ------------------------------ | ---------- | ----------------------------------------- |
| init         | mediaType: String, content: String | 无         | mediaType： 请求体数据类型， content： 请求体内容 |
| contentType   | 无                              | String      | 获取请求体的请求体数据类型                     |
| contentLength | 无                              | Int64       | 获取请求体的长度                             |
| get          | 无                              | InputStream | 获取请求体的输出流                            |

#### class Response

请求的响应

|    成员函数     |              入参               |       返回值        |                作用描述                 |
| -------------- | ------------------------------ | ------------------ | -------------------------------------- |
| newBuilder      | 无                              | ResponseBuilder      | 根据自身配置创建 Builder                   |
| getRequest      | 无                              | String              | 获取对应的 Request 对象                    |
| getProtocol     | 无                              | Protocol            | 获取使用协议                             |
| getCode        | 无                              | Int64               | 获取状态码                               |
| isSuccess       | 无                              | Bool               | 请求是否成功                             |
| getHeaders      | 无                              | Header              | 获取整个响应头                            |
| getHeader       | name: String                     | Option<String>       | 获取Header中key对应的value                 |
| getHeader       | name: String, defaultValue: String | String              | 获取Header中key对应的value,如果没有返回默认值 |
| getBody        | 无                              | Option<ResponseBody> | 获取响应体                               |
| getPrevResponse | 无                              | Option<Response>     | 获取重定向的前置响应对象                   |
| isRedirect      | 无                              | Bool               | 是否是重定向响应                          |
| close          | 无                              | Unit               | 关闭响应体资源                               |
| toString        | 无                              | String              | 格式化输出                               |
| getCacheControl | 无                              | Option<CacheControl> | 获取缓存控制对象                          |

| 静态函数 | 入参 |     返回值      |        作用描述        |
| -------- | ---- | -------------- | -------------------- |
| builder  | 无   | ResponseBuilder | 创建 Response 的Builder |

#### class ResponseBody

响应体

|     成员函数     |                            入参                             |     返回值      |    作用描述     |
| -------------- | ---------------------------------------------------------- | -------------- | ------------- |
| init            | contentType: String, contentLength: Int64, source: ByteArrayStream | 无             | 构造器          |
| getSource        | 无                                                          | ByteArrayStream | 获取响应体字节流 |
| getContentLength | 无                                                          | Int64          | 获取响应体长度   |
| getContentType   | 无                                                          | String         | 获取响应体类型   |


#### class ResponseBuilder

用于创建Response，通过链式调用配置其属性

|   成员函数   |            入参             |     返回值      |                                   作用描述                                    |
| ----------- | --------------------------- | -------------- | --------------------------------------------------------------------------- |
| build        | 无                          | Response        | 通过配置项创建出核心类 Response                                                   |
| request      | request: Request              | ResponseBuilder | 配置原请求对象                                                                 |
| protocol     | protocol: Protocol            | ResponseBuilder | 配置http协议                                                                  |
| code        | code: Int64                  | ResponseBuilder | 配置状态码                                                                    |
| message      | message: String               | ResponseBuilder | 配置状态信息                                                                   |
| header       | name: String, value: String    | ResponseBuilder | 重设响应头key-value键值对                                                       |
| addHeader    | name: String, value: String    | ResponseBuilder | 添加响应头key-value键值对                                                       |
| removeHeader | name: String                 | ResponseBuilder | 移除响应头key-value键值对                                                       |
| prevResponse | prevResponse: Option<Response> | ResponseBuilder | 配置重定向的前置响应对象。注意，如果参数不为None的话，如果响应对象的 body 不为 None，抛异常 |
| body        | body: ResponseBody            | ResponseBuilder | 配置响应体                                                                    |
| header       | header: Header               | ResponseBuilder | 配置响应头                                                                    |

| 静态函数 | 入参 |     返回值      |        作用描述        |
| -------- | ---- | -------------- | -------------------- |
| builder  | 无   | ResponseBuilder | 创建 Response 的Builder |

####  class Chain

拦截器链

|    成员函数    |                              入参                               |      返回值       |      作用描述      |
| ------------- | --------------------------------------------------------------- | ---------------- | ----------------- |
| getTransmitter | 无                                                              | Transmitter        | 获取Transmitter对象 |
| getRequest     | 无                                                              | Request           | 获取请求对象        |
| getExchange    | 无                                                              | Int32             | 获取Exchange对象    |
| proceed        | request: Request                                                  | Transmitter        | 执行拦截器         |
| proceed        | request: Request,  transmitter: Transmitter, exchange: Option<Exchange> | Request           | 执行拦截器重载      |
| getCall        | 无                                                              | Call              | 获取Call对象        |
| getConnection  | 无                                                              | Option<Connection> | 获取连接对象        |

#### Interface Interceptor

默认添加拦截器按顺序有

1.  RetryAndFollowUpInterceptor (负责 HTTP 请求的重定向功能，和重试机制)
2.  BridgeInterceptor(负责桥接功能，把用户所构建的请求转换为真正的 Request，将服务器所返回的响应转换为用户所能够使用的 Response)
3.  CacheInterceptor(主要负责了对缓存的读取以及更新, 目前尚未开发)
4.  ConnectInterceptor(主要负责的是与服务器的连接的建立)
5.  CallServerInterceptor(它真正实现了对服务器连接的读取)

#### Route

连接服务器的路由

|  成员函数   |                     入参                      |  返回值  |                                       作用描述                                       |
| --------- | -------------------------------------------- | ------- | ---------------------------------------------------------------------------------- |
| init       | address: Address, inetSocketAddress: SocketAddress | 无      | address  包含服务器地址和连接协议的对象， inetSocketAddress 标准库SocketAddress类型表示socket地址 |
| getAddress | 无                                            | Address | 获取 Address 对象                                                                     |


#### Address

包含服务器地址和连接协议的对象

|   成员函数   |                入参                |      返回值      |              作用描述               |
| ----------- | ---------------------------------- | --------------- | --------------------------------- |
| init        | url: URL, protocols: ArrayList<String> | 无               | url  服务器URL资源， protocols 请求协议 |
| getUrl       | 无                                 | URL              | 获取 URL 对象                       |
| getProtocols | 无                                 | ArrayList<String> | 获取协议                            |


#### protocol

HTTP_1_1 | H2_PRIOR_KNOWLEDGE

| 成员函数  | 入参 | 返回值  |  作用描述  |
| ------- | ---- | ------ | --------- |
| toString | 无   | String | 格式化输出 |

| 静态函数 |      入参       |  返回值   |      作用描述       |
| -------- | -------------- | ------- | ----------------- |
| get     | protocol: String | Protocol | 字符串转protocol对象 |


#### Transmitter

TCP协议中应用层和传输层的连接流的抽象

|         成员函数          |             入参              | 返回值 |                           作用描述                           |
| ----------------------- | ---------------------------- | ----- | ---------------------------------------------------------- |
| init                     | client: OkHttpClient, call: Call | 无     | client 客户端配置对象，  call 请求的增强                          |
| cancel                   | 无                            | Bool   | 关闭连接                                                     |
| prepareToConnect          | request: Request               | Unit   | 进行准备连接前必要的初始化 如果已经进行过一次连接，判断是否可以可以复用 |
| hasConnection             | 无                            | Bool   | 是否已经建立连接                                              |
| hasExchange               | 无                            | Bool   | 是否已经建立传输通道                                           |
| exchangeDoneDueToException | 无                            | Unit   | 由于异常关闭传输通道                                           |
| canRetry                 | 无                            | Bool   | 是否可以重试                                                 |


#### interface ExchangeCodec

对不同协议解析逻辑的封装

|       成员函数       |      入参       |       返回值        |   作用描述    |
| ------------------- | ---------------- | ------------------ | ------------ |
| write               | request: Request | 无                 | 发送请求      |
| readResponseHeaders   | 无               | ResponseBuilder      | 读取请求头     |
| reportedContentLength | 无              | Int64               | 解析请求体长度 |
| openResponseBody      | 无               | Option<ResponseBody> | 解析请求体     |
| getConnection        | 无               | Connection          | 获取连接对象   |
| cancel               | 无               | Unit               | 关闭连接      |



#### class Exchange

一次完整的http请求的 网络io通道的抽象

|         成员函数          |                                   入参                                    |       返回值        |                           作用描述                           |
| ----------------------- | ------------------------------------------------------------------------ | ------------------ | ---------------------------------------------------------- |
| init                     | transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec | 无                 | 构造器                                                      |
| write                    | 无                                                                        | Bool               | 发送请求                                                     |
| readResponseHeaders        | 无                                                                        | Bool               | 读取请求头                                                   |
| openResponseBody          | 无                                                                        | Option<ResponseBody> | 进行准备连接前必要的初始化 如果已经进行过一次连接，判断是否可以可以复用 |
| getConnection             | 无                                                                        | Connection          | 获取连接                                                     |
| cancel                   | 无                                                                        | Bool               | 关闭通道                                                     |
| detachWithViolence        | 无                                                                        | Unit               | 暴力关闭                                                     |
| noNewExchangesOnConnection | 无                                                                        | Bool               | 标记为此通道不再可用                                                |



#### Connection

包含socket和流的http1.1 ，http2连接

|    成员函数     |                          入参                           |        返回值         |                   作用描述                   |
| -------------- | ------------------------------------------------------- | -------------------- | ------------------------------------------- |
| init           | connectionPool: ConnectionPool, route: Route                 | 无                   | 构造器  connectionPool 连接池对象， route 路由对象 |
| getProtocol     | 无                                                      | Protocol              | 获取协议                                     |
| getTransmitters | 无                                                      | ArrayList<Transmitter> | 获取该连接关联的所有Transmitter实例              |
| noExchanges     | 无                                                      | Unit                 | 标记该连接上不可再传输                          |
| getSocket       | 无                                                      | Option<Socket>        | 获取socket                                   |
| getRoute        | 无                                                      | Route                | 获取路由对象                                  |
| isHealthy       | 无                                                      | Bool                 | 连接是否健康可用                                  |
| isMultiplexed   | 无                                                      | Bool                 | 连接是否支持多路复用                           |
| connect        | connectTimeout: Option<Duration>, connectionRetryEnabled: Bool | Unit                 | 开始连接                                     |
| cancel         | 无                                                      | Unit                 | 关闭socket                                   |

#### ConnectionPool

连接池

|      成员函数       |                                    入参                                    | 返回值 |                                       作用描述                                        |
| ----------------- | ------------------------------------------------------------------------- | ----- | ------------------------------------------------------------------------------------ |
| init               | maxIdleConnections!: Int64 = 5, keepAliveDurationNs!: Duration = Duration.minute(5) | 无     | maxIdleConnections 最大空闲连接数, 默认为5 keepAliveDurationNs 连接最大空闲保持存活时间 默认为5分钟 |
| idleConnectionCount | 无                                                                        | Int64  | 获取当前空闲连接数                                                                      |
| evictAll           | 无                                                                        | Unit   | 移除并关闭所有空闲连接                                                                   |
| connectFailed       | failedRoute: Route                                                          | Unit   | 记录连接失败的路由                                                                      |

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





