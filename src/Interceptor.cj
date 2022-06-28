/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Interceptor interface.
 */
package okhttp

from std import  collection.*

/**
 * The interface is Interceptor
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public interface Interceptor {
   /*
    * The Function is intercept
    *
    * @param chain of Chain
    *
    * @return Type of Response
    * @since 0.29.3
    */
   func intercept(chain: Chain): Response
}

/**
 * The class is Chain
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Chain {
    /* var member interceptors type is ArrayList<Interceptor> */
    private var interceptors: ArrayList<Interceptor>
    /* var member calls type is Int64 */
    private var calls: Int64 = 0
    /* var member index type is Int64 */
    private var index: Int64
    /* var member request type is Request */
    private var request: Request
    /* var member call type is Call */
    private var call: Call

    /**
     * The Function is init constructor
     *
     * @param interceptors of ArrayList<Interceptor>
     * @param index of Int64
     * @param request of Request
     * @param call of Call
     * @since 0.29.3
     */
    public init(interceptors: ArrayList<Interceptor>, index:Int64, request: Request,  call: Call ){
        this.index = index
        this.request = request
        this.call = call
        this.interceptors = interceptors
    }



    /**
     * The Function is getRequest
     *
     * @return Type of Request
     * @since 0.29.3
     */
    public func getRequest(): Request {
        return request
    }

    /**
     * The Function is proceed
     *
     * @param request of Request
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func proceed(request: Request): Response {
        if (index >= interceptors.size()){
            throw Exception("interceptors error")
        }

        calls++
        var next: Chain =  Chain(interceptors, index + 1, request, call)
        let interceptor: Interceptor = interceptors.get(index).getOrThrow();
        let response: Response  = interceptor.intercept(next);

        return response
    }

    /**
     * Returns the connection the request will be executed on. This is only available in the chains
     * of network interceptors: for application interceptors this is always null.
     */
    //func Connection connection():

    /**
     * The Function is getCall
     *
     * @return Type of Call
     * @since 0.29.3
     */
    public func getCall(): Call {
        return call
    }

    /*
     * The Function is connectTimeoutMillis
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    func connectTimeoutMillis(): Int64 {
        return 1
    }

    /*
     * The Function is withConnectTimeout
     *
     * @param timeout of Int64
     * @param unit of TimeUnit
     *
     * @return Type of Chain
     * @since 0.29.3
     */
    func withConnectTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }

    /*
     * The Function is readTimeoutMillis
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    func readTimeoutMillis(): Int64 {
        return 1
    }

    /*
     * The Function is withReadTimeout
     *
     * @param timeout of Int64
     * @param unit of TimeUnit
     *
     * @return Type of Chain
     * @since 0.29.3
     */
    func withReadTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }

    /*
     * The Function is writeTimeoutMillis
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    func writeTimeoutMillis(): Int64 {
        return 1
    }

    /*
     * The Function is withWriteTimeout
     *
     * @param timeout of Int64
     * @param unit of TimeUnit
     *
     * @return Type of Chain
     * @since 0.29.3
     */
    func withWriteTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }
}

/**
 * The class is TimeUnit
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class TimeUnit {


}