/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Address class.
 */
package okhttp

/**
 * The class is Address
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Address {
    /** var member url type is URL */
    public var url: URL
    /**
     * The Function is init constructor
     *
     * @param url of URL
     * @since 0.29.3
     */
    public init (url: URL) {
        this.url = url
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
}

/**
 * The class is Route
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Route {
    /** var member address type is Address */
    public var address: Address
    /** var member inetSocketAddress type is SocketAddress */
    public var inetSocketAddress: SocketAddress

    /**
     * The Function is init constructor
     *
     * @param address of Address
     * @param inetSocketAddress of SocketAddress
     * @since 0.29.3
     */
    public init (address: Address, inetSocketAddress: SocketAddress) {
        this.address = address
        this.inetSocketAddress = inetSocketAddress
    }

    /**
     * The Function is init constructor
     *
     * @param address of Address
     * @since 0.29.3
     */
    public init (address: Address) {
        this.address = address
        this.inetSocketAddress = SocketAddress(address.getUrl().host, parseUInt16(address.getUrl().port()) ?? 0)
    }

    /**
     * The Function is getAddress
     *
     * @return Type of Address
     * @since 0.29.3
     */
    public func getAddress(): Address {
        return address
    }
}

/**
 * The class is RouteSelector
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class RouteSelector {
    /** var member address type is Address */
    public var address: Address
    /* var member call type is Call */
    private var call: Call

    /**
     * The Function is init constructor
     *
     * @param address of Address
     * @param call of Call
     * @since 0.29.3
     */
    public init( address: Address, call: Call) {
        this.address = address
        this.call = call

    }

    /**
     * The Function is next
     *
     * @return Type of Route
     * @since 0.29.3
     */
    public func next():  Route{
        return Route(address)
    }

}
