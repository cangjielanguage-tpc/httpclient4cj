/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Address class.
 */
package okhttp

/**
 * The class is RouteSelector
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
class RouteSelector {
    /** var member address type is Address */
    private let address: Address

    private let routeDatabase: RouteDatabase

    private var index: UInt64 = 0

    private let allRoutes: ArrayList<Route> = ArrayList<Route>()

    /**
     * The Function is init constructor
     *
     * @param address of Address
     * @param call of Call
     * @since 0.29.3
     */
    init(address: Address, routeDatabase: RouteDatabase) {
        this.address = address
        this.routeDatabase = routeDatabase
    }

    /**
     * The Function is next
     *
     * @return Type of Route
     * @since 0.29.3
     */
    public func next(): Option<Route> {
        match (resolveDomain(TCP, address.getUrl().hostname(), index)) {
            case Some(route) =>
                index++
                let url = address.getUrl()
                let port:UInt16 = match(parseUInt16(url.port())){
                    case Some(v) =>  v
                    case None =>
                        if (url.toString().startsWith("https")) {
                            443
                        } else {
                            80
                        }
                }
                let nextRoute =  Route(address, SocketAddress(route[0], route[1], port))
                if (!routeDatabase.shouldPostpone(nextRoute)) {
                    return nextRoute
                } else {
                    return next()
                }
            case None => return None
        }
    }

    public func hasNext(): Bool {
        match (resolveDomain(TCP, address.getUrl().hostname(), index)) {
            case Some(r) =>
                return true
            case None => return false
        }
    }

    public func getAll(): ArrayList<Route> {
        if(!allRoutes.isEmpty()) {
            return allRoutes
        }
        let routes: ArrayList<Route> = ArrayList<Route>()
        var index: UInt64 =0
        while(true) {
            match (resolveDomain(TCP, address.getUrl().hostname(), index)) {
                case Some(route) =>
                    let url = address.getUrl()
                    let port:UInt16 = match(parseUInt16(url.port())){
                        case Some(v) => v
                        case None =>
                            if (url.toString().startsWith("https")) {
                                443
                            } else {
                                80
                            }
                    }
                    routes.append(Route(address, SocketAddress(route[0], route[1], port)))
                case None => break
            }
            index++
        }
        allRoutes.appendAll(routes)
        return routes
    }

    public func clone(): RouteSelector {
        return RouteSelector(address, routeDatabase)
    }
}