/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the RealCall class.
 */
package okhttp

from std import sync.*

/**
 * The interface is Call
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public interface Call {
    /*
     * The Function is request
     *
     * @return Type of Request
     * @since 0.29.3
     */
    func request(): Request
    /*
     * The Function is execute
     *
     * @return Type of Response
     * @since 0.29.3
     */
    func execute(): Response
    /*
     * The Function is enqueue
     *
     * @param responseCallback of Callback
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func enqueue(responseCallback: Callback):Unit

    /*
     * The Function is cancel
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func cancel(): Unit
    /*
     * The Function is isExecuted
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func isExecuted(): Bool
    /*
     * The Function is isCanceled
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    func isCanceled(): Bool
    /*
     * The Function is timeout
     *
     * @return Type of Timeout
     * @since 0.29.3
     */
    func timeout(): Timeout
    /*
     * The Function is clone
     *
     * @return Type of Call
     * @since 0.29.3
     */
    func clone(): Call
}



/**
 * The class is RealCall inherited from Call
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class RealCall <:  Call {
    /** var member forWebSocket type is Bool */
    public var forWebSocket: Bool = false

    /**
     * The Function is request
     *
     * @return Type of Request
     * @since 0.29.3
     */
    public func request(): Request {
        return Request.builder().build()
    }
    /**
     * The Function is execute
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func execute(): Response {
        return Response.builder().build()
    }
    /**
     * The Function is enqueue
     *
     * @param responseCallback of Callback
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func enqueue(responseCallback: Callback):Unit {

    }

    /**
     * The Function is cancel
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    public func cancel(): Unit {

    }

    /**
     * The Function is isExecuted
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func isExecuted(): Bool {
        return false
    }
    /**
     * The Function is isCanceled
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func isCanceled(): Bool {
        return false
    }
    /**
     * The Function is timeout
     *
     * @return Type of Timeout
     * @since 0.29.3
     */
    public func timeout(): Timeout {
        return Timeout()
    }
    /**
     * The Function is clone
     *
     * @return Type of Call
     * @since 0.29.3
     */
    public func clone(): Call {
        return this
    }

    /**
     * The Function is getResponseWithInterceptorChain
     *
     * @return Type of Response
     * @since 0.29.3
     */
    public func getResponseWithInterceptorChain(): Response {
       return Response.builder().build()
    }

    /**
     * The Function is newRealCall
     *
     * @param client of OkHttpClient
     * @param originalRequest of Request
     * @param forWebSocket of Bool
     * @since 0.29.3
     */
    public static func newRealCall( client: OkHttpClient,  originalRequest: Request,  forWebSocket: Bool) {
       return RealCall()
    }

}

/**
 * The class is AsyncCall
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class AsyncCall {
     /** var member callsPerHost type is AtomicInt64 */
     public var callsPerHost: AtomicInt64 = AtomicInt64(0)
     /* let member responseCallback type is Callback */
     private let  responseCallback: Callback
     /* let member realCall type is RealCall */
     private let  realCall: RealCall

     /*
      * The Function is init constructor
      *
      * @param responseCallback of Callback
      * @param realCall of RealCall
      * @since 0.29.3
      */
     init(responseCallback: Callback, realCall: RealCall) {
        this.responseCallback = responseCallback
        this.realCall = realCall
     }

     /*
      * The Function is reuseCallsPerHostFrom
      *
      * @param other of AsyncCall
      *
      * @return Type of Unit
      * @since 0.29.3
      */
     func reuseCallsPerHostFrom( other: AsyncCall): Unit {
         this.callsPerHost = other.callsPerHost;
     }

     /*
      * The Function is get
      *
      * @return Type of RealCall
      * @since 0.29.3
      */
     func get(): RealCall {
       return RealCall()
     }

     /*
      * The Function is host
      *
      * @return Type of String
      * @since 0.29.3
      */
     func host(): String {
        return ""
     }

     /*
      * The Function is executeOn
      *
      * @since 0.29.3
      */
     func executeOn() {
        spawn {
            execute()
        }
     }


     /*
      * The Function is execute
      *
      * @since 0.29.3
      */
     func execute() {
        try {
         let response: Response = realCall.getResponseWithInterceptorChain()
            responseCallback.onResponse(realCall, response)
         } catch(e : Exception) {
            responseCallback.onFailure(realCall, e)
            throw e
         }
     }
}

/**
 * The class is Timeout
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Timeout{

}