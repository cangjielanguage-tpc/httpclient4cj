/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the NoneEventListener class.
 */
package okhttp


/*
 * The class is NoneEventListener inherited from EventListener
 * @author luoyukai4
 * @since 0.35.6
 */
class NoneEventListener <: EventListener{

    public func callStart(call: Call): Unit {}

    public func callEnd(call: Call): Unit {}

    public func dnsStart(call: Call, domainName: String): Unit {}

    public func dnsEnd(call: Call, domainName: String, allRoutes: ArrayList<Route>): Unit {}

    public func connectStart(call: Call, socketAddress: SocketAddress): Unit {}

    public func connectEnd(call: Call, socketAddress: SocketAddress, protocol: Protocol): Unit {}

    public func secureConnectStart(call: Call): Unit {}

    public func secureConnectEnd(call: Call, tlsConfig: TlsClientConfig): Unit {}

    public func connectFailed(call: Call, socketAddress: SocketAddress, protocol: Protocol, e: HttpException ): Unit {}

    public func requestHeadersStart(call: Call): Unit {}

    public func requestHeadersEnd(call: Call): Unit {}

    public func requestBodyStart(call: Call): Unit {}

    public func requestBodyEnd(call: Call, byteCount: Int64): Unit {}

    public func requestFailed(call: Call, e: HttpException): Unit {}

    public func responseHeadersStart(call: Call): Unit {}

    public func responseHeadersEnd(call: Call, response: Response): Unit {}

    public func responseBodyStart(call: Call): Unit {}

    public func responseBodyEnd(call: Call, byteCount: Int64): Unit {}

    public func responseFailed(call: Call, e: HttpException): Unit {}
}