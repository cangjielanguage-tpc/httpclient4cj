/**
 * @file
 * The file declares the Address class.
 */

package httpclient4cj

/**
 * The class is Address
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Address <: Hashable & Equatable<Address> {
    /** var member url type is URL */
    public var url: URL
    private var tlsConfig: Option<TlsClientConfig>

    private var protocols: ArrayList<String>

    /**
     * The Function is init constructor
     *
     * @param url of URL
     * @since 0.29.3
     */
    public init(url: URL, protocols: ArrayList<String>, tlsConfig: Option<TlsClientConfig>) {
        this.url = url
        this.protocols = protocols
        this.tlsConfig = tlsConfig
    }

    public init(url: URL, protocols: ArrayList<String>) {
        this.url = url
        this.protocols = protocols
        this.tlsConfig = None
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
     * The Function is getProtocols
     *
     * @return Type of ArrayList<String>
     * @since 0.30.4.
     */
    public func getProtocols(): ArrayList<String> {
        return protocols
    }

    /**
     * The Function is getTlsConfig
     *
     * @return Type of Option<TlsClientConfig> >
     * @since 0.30.4.
     */
    public func getTlsConfig(): Option<TlsClientConfig> {
        return tlsConfig
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = 31 * result + url.toString().hashCode()
        var listCode = 1
        for (i in 0..protocols.size) {
            listCode = 31 * listCode + protocols[i].toString().hashCode()
        }
        result = 31 * result + listCode
        return result
    }

    public operator func ==(rhs: Address): Bool {
        if (!equalsProtocols(rhs)) {
            return false
        }
        let tlsEqual = equalsTlsConfig(rhs)
        // 同一 URL 对象（复用 Request 时常见）无需再序列化比较字符串
        if (!refEq(url, rhs.url)) {
            if (!url.toString().equals(rhs.getUrl().toString())) {
                return false
            }
        }
        return tlsEqual
    }

    public operator func !=(rhs: Address): Bool {
        return !(this == rhs)
    }

    func equalsProtocols(rhs: Address): Bool {
        if (protocols.size != rhs.protocols.size) {
            return false
        }
        for (i in 0..protocols.size) {
            if (protocols[i] != rhs.protocols[i]) {
                return false
            }
        }
        return true
    }

    func equalsTlsConfig(rhs: Address): Bool {
        let path1 = match (tlsConfig) {
            case Some(ts) => ts.serverName ?? ""
            case None => ""
        }
        let path2 = match (rhs.getTlsConfig()) {
            case Some(ts) => ts.serverName ?? ""
            case None => ""
        }
        return path1.equals(path2)
    }
}
