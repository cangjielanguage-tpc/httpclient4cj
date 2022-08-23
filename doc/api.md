### 接口说明

主要是核心类和成员函数说明

#### class RealCall

```
public func getRequest(): Request
public func getTransmitter(): Transmitter
public func execute(): Response
public func enqueue(responseCallback: Callback): Unit
public func cancel(): Unit
public func isExecuted(): Bool
public func isCanceled(): Bool
public func timeout(): Timeout
public func clone(): Call
public func getResponseWithInterceptorChain(): Response
public static func newRealCall(client: OkHttpClient, originalRequest: Request, forWebSocket: Bool): RealCall
```

#### class AsyncCall

```
public func cancel()
public func executeOn(): Unit
public func execute(): Unit
```
#### class ConnectInterceptor

```
public init (client: OkHttpClient)
public func intercept(chain: Chain): Response
```

#### class Dispatcher

```
public func setIdleCallback(idleCallback: Option<()-> Unit>)
public func setMaxRequests(maxRequests: Int64): Unit
public func getMaxRequests(): Int64
public func setMaxRequestsPerHost(maxRequestsPerHost: Int64): Unit
public func getMaxRequestsPerHost(): Int64
public func cancelAll()
public func queuedCallsCount()
public func runningCallsCount(): Int64
```

#### class Chain

```
public init(interceptors: ArrayList<Interceptor>, index:Int64, request: Request, call: Call )
public func getTransmitter(): Transmitter
public func getRequest()
public func getExchange(): Exchange
public func proceed(request: Request,  transmitter: Transmitter, exchange: Option<Exchange>): Response
public func proceed(request: Request): Response
public func getCall(): Call
public func getConnection(): Option<Connection>
```

#### class OkHttpClient

```
public init(builder: OkHttpClientBuilder)
public static func builder(): OkHttpClientBuilder
public func newCall(request: Request): Call
public func getFollowRedirects(): Bool
public func getRetryOnConnectionFailure()
public func getConnectionPool(): Option<ConnectionPool>
public func getDispatcher(): Dispatcher
public func getInterceptors(): ArrayList<Interceptor>
public func getNetworkInterceptors(): ArrayList<Interceptor>
public func getCookieJar(): CookieJar
public func getConnectTimeout(): Option<Duration>
public func getReadTimeout(): Option<Duration>
public func getWriteTimeout(): Option<Duration>
public func getProtocols(): ArrayList<String>
public func getTlsConfig(): Option<TlsConfig>
```

#### class OkHttpClientBuilder

```
public func dispatcher(dispatcher: Dispatcher): OkHttpClientBuilder
public func build(): OkHttpClient
public func followRedirects(followRedirects: Bool): OkHttpClientBuilder
public func retryOnConnectionFailure(retryOnConnectionFailure: Bool): OkHttpClientBuilder
public func connectionPool(connectionPool: Option<ConnectionPool>): OkHttpClientBuilder
public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder
public func addNetworkInterceptor(interceptor: Interceptor): OkHttpClientBuilder
public func cookieJar(cookieJar: CookieJar): OkHttpClientBuilder
public func connectTimeout(connectTimeout: Duration): OkHttpClientBuilder
public func readTimeout(readTimeout: Duration): OkHttpClientBuilder
public func writeTimeout(writeTimeout: Duration): OkHttpClientBuilder
public func tlsConfig(path: String): OkHttpClientBuilder
public func protocols(protocols: ArrayList<String>): OkHttpClientBuilder

```

#### enum Protocol

```
| HTTP_1_0
| HTTP_1_1
| SPDY_3 
| HTTP_2 
| H2_PRIOR_KNOWLEDGE 
| QUIC
public static func get(protocol: String)
public func toString()
```

#### class ConcurrentQueue<T>

```
public init()
public init(size: Int64)
public func iterator(): Iterator<T>
public func get(index: Int64): T
public func remove(index: Int64)
public func removeIf(predicate: (T) -> Bool)
public func add(item: T)
public func size(): Int64
```

#### class Request

```
public init(builder: RequestBuilder)
public func getUrl()
public func getMethod()
public func getBody(): Option<RequestBody>
public static func builder()
public func newBuilder(): RequestBuilder
public func getHeaders(): Header
public func getHeader(name: String): String
public func getHeader(name: String, defaultValue: String): String
public func toHttpRequest()
public func getCacheControl(): Option<CacheControl>
```

#### class RequestBuilder

```
public init(request: Request)
public init()
public func url(url: String): RequestBuilder
public func url(url: URL): RequestBuilder
public func header( name: String, value: String): RequestBuilder
public func method(method: String): RequestBuilder
public func body(requestBody: RequestBody): RequestBuilder
public func build(): Request
public func removeHeader(name: String): RequestBuilder
public func header(header: Header): RequestBuilder
public func cacheControl(cacheControl: CacheControl): RequestBuilder
```

#### class Response

```
public init(builder: ResponseBuilder)
public func getRequest(): Request
public func getProtocol(): Protocol
public func getCode(): Int64
public func isSuccess(): Bool
public func getMessage(): String
public func getHeaders(): Header
public func getHeader(name: String): String
public func getHeader(name: String, defaultValue: String): String
public func getBody(): Option<ResponseBody>
public func getPrevResponse(): Option<Response>
public func isRedirect(): Bool
public func close()
public func toString(): String
public static func builder(): ResponseBuilder
public func newBuilder(): ResponseBuilder
public func getCacheControl(): Option<CacheControl>
```

#### class ResponseBody

```
public init(contentType: String, contentLength: Int64, source: StringStream)
public init()
public func getSource(): StringStream
public func close(): Unit
public func getContentLength(): Int64
```

#### class ResponseBuilder

```
public init()
public init(response: Response)
public func request(request: Request): ResponseBuilder
public func protocol(protocol: Protocol): ResponseBuilder
public func code(code: Int64): ResponseBuilder
public func message(message: String): ResponseBuilder
public func header(name: String, value: String): ResponseBuilder
public func addHeader(name: String, value: String): ResponseBuilder
public func removeHeader( name: String): ResponseBuilder
public func prevResponse(prevResponse: Option<Response>): ResponseBuilder
public func body(body: Option<ResponseBody>): ResponseBuilder
public func header(header: Header): ResponseBuilder
public func build(): Response
```

#### class RetryAndFollowUpInterceptor

```
public init(client: OkHttpClient)
public func intercept(chain: Chain): Response
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

#### class Address 

```
public init (url: URL, protocols: ArrayList<String>, tlsConfig: Option<TlsConfig>)
public func getUrl(): URL
public func getProtocols(): ArrayList<String>
public func getTlsConfig(): Option<TlsConfig>
```

#### class Route

```
public init (address: Address, inetSocketAddress: SocketAddress)
public init (address: Address)
public func getAddress(): Address
```

#### class RouteSelector

```
public init( address: Address, call: Call)
public func next():  Route
```

#### class BridgeInterceptor

```
public init(cookieJar: CookieJar)
public func intercept(chain: Chain): Response
```

#### class CacheControlBuilder

```
public func noCache(): CacheControlBuilder
public func noStore(): CacheControlBuilder
public func maxAge(timeUnit: Duration): CacheControlBuilder
public func maxStale(timeUnit: Duration): CacheControlBuilder
public func minFresh(timeUnit: Duration): CacheControlBuilder
public func onlyIfCached(): CacheControlBuilder
public func noTransform(): CacheControlBuilder
public func immutable(): CacheControlBuilder
public func build(): CacheControl
```

#### class CacheControl

```
public static let FORCE_NETWORK: CacheControl
public static let FORCE_CACHE: CacheControl
public init(builder: CacheControlBuilder)
public static func builder(): CacheControlBuilder
public func noCache(): Bool
public func noStore(): Bool
public func maxAgeSeconds(): Int32
public func sMaxAgeSeconds(): Int32
public func isPrivate(): Bool
public func isPublic(): Bool
public func mustRevalidate(): Bool
public func maxStaleSeconds(): Int32
public func minFreshSeconds(): Int32
public func onlyIfCached(): Bool
public func noTransform(): Bool
public func immutable(): Bool
public static func parse(header: Header): CacheControl
public func toString(): String
```

#### class CallServerInterceptor

```
public init (forWebSocket: Bool)
public func intercept(chain: Chain): Response
```

#### class ExchangeFinder

```
public init (transmitter: Transmitter, connectionPool: ConnectionPool, address: Address, call: Call)
public func find(client: OkHttpClient, chain: Chain, doExtensiveHealthChecks: Bool): ExchangeCodec
```

#### class Exchange

```
public init (transmitter: Transmitter, call: Call, finder: ExchangeFinder, codec: ExchangeCodec)
public func write(request: Request): Unit
public func readResponseHeaders(): ResponseBuilder
public func openResponseBody(): Option<ResponseBody>
public func getConnection(): Connection
```

#### class Connection

```
public init(connectionPool: ConnectionPool, route: Route)
public func getProtocol(): Protocol
public func getTransmitters(): ArrayList<Transmitter>
public func noExchanges(): Unit
public func getSocket(): Option<Socket>
public func getRoute(): Route
public func isEligible(address: Address): Bool
public func isMultiplexed(): Bool
public func connect(connectTimeout: Option<Duration>)
public func newCodec(client: OkHttpClient, chain: Chain): ExchangeCodec
public func cancel(): Unit
```

#### class ConnectionPool

```
public init(maxIdleConnections: Int64)
public func connectionCount(): Int64
public func idleConnectionCount(): Int64
public func evictAll(): Unit
```
#### class RequestBody

```
public init(mediaType: String, content: String)
public func contentType(): String
public func contentLength(): Int64
public func get(): ReadCloseStream
```

#### class StatusLine

```
public static var HTTP_TEMP_REDIRECT: Int64 = 307
public static var HTTP_PERM_REDIRECT: Int64 = 308
public static var HTTP_MULT_CHOICE: Int64 = 300
public static var HTTP_MOVED_PERM: Int64 = 301
public static var HTTP_MOVED_TEMP: Int64 = 302
public static var HTTP_SEE_OTHER: Int64 = 303
```

#### class Transmitter

```
public init (client: OkHttpClient, call: Call)
public func cancel()
public func isCanceled()
public func releaseConnectionNoEvents(): Option<Socket>
public func acquireConnectionNoEvents(connection: Connection): Unit
public func prepareToConnect(request: Request): Unit
public func newExchange(chain: Chain, doExtensiveHealthChecks: Bool): Exchange
```

#### class Util

```
public static func closeQuietly(socket: Option<Socket>)
public static func sameConnection( a: URL, b: URL): Bool
public static func getRequestMethod(method: String): RequestMethod
public static func skipUntil(input: String, pos: Int32, characters: String): Int32
public static func skipWhitespace(input: String, pos: Int32): Int32
public static func parseSeconds(value: String, defaultValue: Int32): Int32
```

#### enum SocketClient

```
| SocketC(Socket)
| TlsC(TlsSocket)
public func connect(): Unit
```