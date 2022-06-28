### 接口说明

主要是核心类和成员函数说明

#### class RealCall

```
public func request()
public func execute()
public func enqueue(responseCallback: Callback)
public func cancel()
public func isExecuted()
public func isCanceled()
public func timeout()
public func clone()
public func getResponseWithInterceptorChain()
public static func newRealCall( client: OkHttpClient,  originalRequest: Request,  forWebSocket: Bool)
```

#### calss ConnectInterceptor

```
public init (client: OkHttpClient)
public func intercept(chain: Chain)
```

#### class Dispatcher

```
public func setMaxRequests(maxRequests: Int64)
public func executed( call: RealCall)
public func enqueue( call: AsyncCall)
```

#### class Chain

```
public init(interceptors: ArrayList<Interceptor>, index:Int64, request: Request,  call: Call )
public func getRequest()
public func proceed(request: Request)
public func getCall()
```

#### class OkHttpClient

```
public init(builder: OkHttpClientBuilder)
public static func builder()
public func newCall(request: Request)
public func getFollowRedirects()
```

#### class OkHttpClientBuilder

```
public func addInterceptor(interceptor: Interceptor)
public func build()
```

#### enum Protocol

```
public static func get(protocol: String)
public func toString()
```

#### class ConcurrentQueue<T>

```
public init()
public init(size: Int64)
public func iterator()
public func add(item: T)
public func poll()
public func recycle()
public func toArrayList()
```

#### class Request

```
public init(builder: RequestBuilder)
public func getUrl()
public func getMethod()
public static func builder()
```

#### class RequestBuilder

```
public func url(url: String)
public func header( name: String, value: String)
public func method(method: String)
public func build()
```

#### class Response

```
public init(builder: ResponseBuilder)
public func getRequest()
public func getProtocol()
public func getCode()
public func isSuccess()
public func getMessage()
public func getHeaders(name: String)
public func getHeader(name: String)
public func getHeader(name: String, defaultValue: String)
public func getHeaders()
public func getBody(body: ResponseBody)
public func isRedirect()
public func close()
public func toString()
public static func builder()
```

#### class ResponseBody

```
public init(source: BufferStream)
public func getSource()
public func close()
```

#### class ResponseBuilder

```
public func request(request: Request)
public func protocol(protocol: Protocol)
public func code(code: Int64)
public func message(message: String)
public func header(name: String, value: String)
public func addHeader(name: String, value: String)
public func removeHeader( name: String)
public func body(body: ResponseBody)
public func build()
```

#### class RetryAndFollowUpInterceptor

```
public init(client: OkHttpClient)
public func intercept(chain: Chain)
```

#### class Transport

```
public static func getDefault()
public func roundTrip(req: http.Request)
public static func validMethod(method: String)
```

#### class PersistConn

```
public init(conn : Option<Socket>)
public func roundTripTrans(request: http.Request)
public func setClientoTimeDuration(clientoTime!: Option<Duration> = None)
public func parseHead()
public func parseBody(request: http.Request)
```