/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 * The file declares the Request class.
 */

package httpclient4cj

internal import std.sync.*

/**
 * The class is Request
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Request <: ToString {
    // Request 构造后不再变化（对齐 OkHttp 的不可变 Request），可安全跨线程共享
    /* var member url type is URL */
    let url: URL

    /* var member header type is Header，构造时冻结为只读 */
    let header: Header

    /* var member method type is String */
    let method: String

    /* var member body type is Option<RequestBody> */
    let body: Option<RequestBody>

    // 快路径请求字节：首次使用时在锁内计算并写回（内容确定，重复写回同值无害）
    private var fastPathWire: Array<Byte> = Array<Byte>(0, repeat: 0)
    private var fastPathWireGzip: Bool = false
    private var fastPathWireModCount: Int64 = -1
    private static let FAST_PATH_WIRE_LOCK: Mutex = Mutex()

    let tags: Option<HashMap<String, Tag>>

    /**
     * The Function is init constructor
     *
     * @param builder of RequestBuilder
     * @since 0.29.3
     */
    public init(builder: RequestBuilder) {
        this.url = builder.urlBuild
        // clone 是写时复制：与 Builder 共享底层存储，任一实例修改时才真正拷贝
        let header = builder.headerBuild.clone()
        // 冻结请求头：Request 构造后不允许再被修改，避免共享请求被并发改写
        header.freeze()
        this.header = header
        this.method = builder.methodBuild
        this.body = builder.bodyBuild
        // 拷贝 tags，避免构造后仍与 Builder 共享同一个可变 Map
        this.tags = match (builder.getTagsOpt()) {
            case Some(m) => Option<HashMap<String, Tag>>.Some(HashMap<String, Tag>(m))
            case None => Option<HashMap<String, Tag>>.None
        }
    }

    /**
     * The Function is getUrl
     *
     * @return Type of URL
     * @since 0.29.3
     */
    public func getUrl(): URL {
        return url
    }

    /**
     * The Function is getMethod
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func getMethod(): String {
        return method
    }

    /**
     * The Function is getBody
     *
     * @return Type of Option<RequestBody>
     * @since 0.29.3
     */
    public func getBody(): Option<RequestBody> {
        return body
    }

    /**
     * The Function is builder
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public static func builder(): RequestBuilder {
        return RequestBuilder()
    }

    /**
     * The Function is newBuilder
     *
     * @return Type of RequestBuilder
     * @since 0.29.3
     */
    public func newBuilder(): RequestBuilder {
        return RequestBuilder(this)
    }

    /**
     * The Function is getHeaders
     *
     * @return Type of Header
     * @since 0.29.3
     */
    public func getHeaders(): Header {
        return header
    }

    /**
     * The Function is getHeader
     *
     * @param name of String
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func getHeader(name: String): Option<String> {
        return header.getString(name)
    }

    /**
     * The Function is getHeader
     *
     * @param name of String
     * @param defaultValue of String
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func getHeader(name: String, defaultValue: String): String {
        return header.getString(name) ?? defaultValue
    }

    public func toString(): String {
        return "Request{method= ${method}, url= ${url.toString()}}"
    }

    /**
     * Returns the cache control directives for this response. This is never null, even if this
     * response contains no {@code Cache-Control} header.
     *
     * @since 0.30.4
     */
    public func getCacheControl(): CacheControl {
        // 不做惰性缓存：Request 可跨线程共享，缓存字段的写入会引入数据竞争；
        // 解析开销很小，且 header 已冻结，直接解析即可
        return CacheControl.parse(header)
    }

    public func getTag(s: String): Tag {
        match (tags) {
            case Some(m) => if (m.contains(s)) {
                return m[s]
            } else {
                return Tag("")
            }
            case None => return Tag("")
        }
    }

    // 保留原有 API；tags 已在构造时拷贝，因此只会修改本实例的私有副本
    public func removeTag(s: String): Unit {
        match (tags) {
            case Some(m) => m.remove(s)
            case None => ()
        }
    }

    /**
     * 返回快路径可直接写入 socket 的请求字节，以及是否为透明 gzip 添加了 Accept-Encoding。
     * 读写缓存字段全程持锁，避免并发首次计算时读到未完整发布的数据。
     */
    func getFastPathWire(): (Array<Byte>, Bool) {
        synchronized(FAST_PATH_WIRE_LOCK) {
            if (fastPathWire.size > 0 && fastPathWireModCount == header.modCount) {
                return (fastPathWire, fastPathWireGzip)
            }
            let wire = buildFastPathRequestBytes(this)
            fastPathWire = wire[0]
            fastPathWireGzip = wire[1]
            fastPathWireModCount = header.modCount
            return wire
        }
    }

}

public class Tag {
    public var tag: String

    public init(tag: String) {
        this.tag = tag
    }
}
