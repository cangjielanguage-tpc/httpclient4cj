## cache_control 设计文档

### 原理

客户端从服务器请求数据需要经历如下基本步骤: 
1、如果请求命中本地缓存则从本地缓存中获取一个对应资源的"copy"； 
2、检查这个"copy"是否fresh,是则直接返回，否则继续向服务器转发请求。 
3、服务器接收到请求，然后判断资源是否变更，是则返回新内容，否则返回304，未变更。 
4、客户端更新本地缓存

### 主要类和接口

#### `class CacheControlBuilder`

```
public class CacheControlBuilder <: Builder<CacheControl> {
    public var noCacheBuild: Bool = true
    
    public var noStoreBuild: Bool = true
    
    public var maxAgeSeconds: Int32 = -1
    
    public var maxStaleSeconds: Int32 = -1
    
    public var minFreshSeconds: Int32 = -1
    
    public var onlyIfCachedBuild: Bool = true
    
    public var noTransformBuild: Bool = true
    
    public var immutableBuild: Bool = true
   
    // 强制客户端跳过步骤2，直接向服务器发送请求。也就是说每次请求都必须向服务器发送
    public func noCache(): CacheControlBuilder

    // 缓存将不存储 response，包括 header 和 body
    public func noStore(): CacheControlBuilder

    // 响应服务日期后最大持续时间
    public func maxAge(timeUnit: Duration): CacheControlBuilder

    // 指示客户可以接收超出 max-age 时间的响应消息，max-stale 在请求设置中有效，在响应设置中无效
    public func maxStale(timeUnit: Duration): CacheControlBuilder

    // 设置响应将继续保持新鲜的最小秒数。如果响应将是陈旧的，缓存的响应将不会被使用，将发出网络请求
    public func minFresh(timeUnit: Duration): CacheControlBuilder

    // 仅接受缓存中的响应。如果响应没有被缓存, 响应将被返回
    public func onlyIfCached(): Bool

    // 如果第三方网站不希望页面被客户端转码，可在页面中添加此协议，当用户进入时，会直接跳转至原网页
    public func noTransform(): Bool

    // 当一个支持immutable的客户端浏览器看到这个属性时，它应该知道：如果没有超过时间上的过期失效时间，那么服务器端该页面内容将不会改变，这样浏览器就不应该再发送有条件的重新验证请求
    public func immutable(): CacheControlBuilder

    public func build(): CacheControl
}
```

#### `class CacheControl`

```
public class CacheControl {
    public static let FORCE_NETWORK
    public static let FORCE_CACHE
    
    public init(builder: CacheControlBuilder)

    public static func builder(): CacheControlBuilder

    public func noCache(): Bool

    public func noStore(): Bool

    public func maxAgeSeconds(): Int32

    public func sMaxAgeSeconds(): Int32

    // // 仅体现在响应头，通知浏览器只针对单个用户缓存响应. 且可以具体指定某个字段.如private –“username”
    public func isPrivate(): Bool

    // 仅体现在响应头,通知浏览器可以无条件的缓存该响应 客户端和代理服务器都可以缓存该资源
    public func isPublic(): Bool

    // 作用与 no-cache 相同，但更严格，强制意味更明显
    public func mustRevalidate(): Bool

    public func maxStaleSeconds(): Int32

    public func minFreshSeconds(): Int32

    public func onlyIfCached(): Bool

    public func noTransform(): Bool

    public func immutable(): Bool

    // Headers   
    public static func parse(header: Header): CacheControl

    public func toString(): String

}


```
