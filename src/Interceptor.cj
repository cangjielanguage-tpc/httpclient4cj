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
    /* var member transmitter type is Transmitter */
    private var transmitter: Transmitter
    /* var member calls type is Int64 */
    private var calls: Int64 = 0
    /* var member index type is Int64 */
    private var index: Int64
    /* var member request type is Request */
    private var request: Request
    /* var member call type is Call */
    private var call: Call
    /* var member exchange type is Option<Exchange> */
    private var exchange: Option<Exchange> = None
    private var connectTimeout: Option<Duration>
    private var readTimeout: Option<Duration>
    private var writeTimeout: Option<Duration>

    /**
     * The Function is init constructor
     *
     * @param interceptors of ArrayList<Interceptor>
     * @param transmitter of Transmitter
     * @param index of Int64
     * @param request of Request
     * @param call of Call
     * @param exchange of Option<Exchange>
     * @since 0.29.3
     */
    public init(interceptors: ArrayList<Interceptor>, transmitter: Transmitter , index:Int64, request: Request,
        call: Call, exchange: Option<Exchange>, connectTimeout:Option<Duration>, readTimeout:Option<Duration>,
            writeTimeout: Option<Duration>){
        this.transmitter = transmitter
        this.index = index
        this.request = request
        this.call = call
        this.interceptors = interceptors
        this.exchange = exchange
        this.connectTimeout = connectTimeout
        this.readTimeout = readTimeout
        this.writeTimeout = writeTimeout
    }

    /**
     * The Function is getTransmitter
     *
     * @return Type of Transmitter
     * @since 0.29.3
     */
    public func getTransmitter(): Transmitter{
        return transmitter
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
     * The Function is getExchange
     *
     * @return Type of Exchange
     * @since 0.29.3
     */
    public func getExchange(): Exchange {
        return exchange.getOrThrow()
    }

    /**
     * The Function is proceed
     *
     * @param request of Request
     * @param transmitter of Transmitter
     * @param exchange of Option<Exchange>
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func proceed(request: Request,  transmitter: Transmitter, exchange: Option<Exchange>): Response {
        if (index >= interceptors.size()){
            throw Exception("interceptors error")
        }
        calls++
        var next: Chain =  Chain(interceptors,transmitter, index + 1, request, call, exchange, connectTimeout,
         readTimeout, writeTimeout )
        let interceptor: Interceptor = interceptors.get(index).getOrThrow();
        let response: Response  = interceptor.intercept(next)
        return response
    }

    /**
     * The Function is proceed
     *
     * @param request of Request
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func proceed(request: Request): Response{
        return proceed(request, transmitter, exchange);
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