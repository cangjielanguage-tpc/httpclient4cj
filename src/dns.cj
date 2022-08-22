/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Address class.
 */
package okhttp

public func getAddInfo(socket: String): Array<IpAddress> {
    return [IpAddress(SocketAddressKind.IPv4, Array<UInt8>(32, item: 0))]
}


public struct IpAddress {
    public var kind: SocketAddressKind
    public var ips:  Array<UInt8>

    public init(kind: SocketAddressKind, ips:  Array<UInt8>) {
        this.kind = kind
        this.ips = ips
    }
}