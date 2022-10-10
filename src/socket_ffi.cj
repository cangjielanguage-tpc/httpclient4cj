package okhttp

let AI_IPPROTO_TCP: UInt8 = 6
let AI_IPPROTO_UDP: UInt8 = 17

let SOCK_ADDR_IPV4_LEN: Int64 = 4
let SOCK_ADDR_IPV6_LEN: Int64 = 16

foreign {
    func okhttp_SOCKET_GetAddrInfo(net: UInt8, damin: CString, index: UInt64): CPointer<UInt8>
    @fastNative
    func free(ptr: CPointer<Unit>): Unit
}

func resolveDomain(net: SocketNet, domain: String, index: UInt64): Option<(SocketAddressKind, Array<UInt8>)> {
    var protocol = match (net) {
        case TCP => AI_IPPROTO_TCP
        case UDP => AI_IPPROTO_UDP
    }
    var domainName = CString(domain)
    var ip = unsafe { okhttp_SOCKET_GetAddrInfo(protocol, domainName, index)}
    unsafe { domainName.free() }
    if (ip.isNull()) {
        return None
    }
    let sz = Int64(unsafe { ip.read() })
    if (sz != SOCK_ADDR_IPV4_LEN && sz != SOCK_ADDR_IPV6_LEN) {
        unsafe { free(CPointer<Unit>(ip)) }
        return None
    }
    var arr = Array<UInt8>(sz, item: 0)
    for (i in 0..sz) {
        arr[i] = unsafe { ip.read(i + 1)}
    }
    unsafe { free(CPointer<Unit>(ip)) }
    return match {
        case sz == SOCK_ADDR_IPV4_LEN => Some((IPv4, arr))
        case _ => Some((IPv6, arr))
    }
}
