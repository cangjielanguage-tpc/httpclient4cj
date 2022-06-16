package okhttp

from std import sync.*

public interface Call {
    func request(): Request
    func execute(): Response
    func enqueue(responseCallback: Callback):Unit

    func cancel(): Unit
    func isExecuted(): Bool
    func isCanceled(): Bool
    func timeout(): Timeout
    func clone(): Call
}



public class RealCall <:  Call {
    public var forWebSocket: Bool = false

    public func request(): Request {
        return Request.builder().build()
    }
    public func execute(): Response {
        return Response.builder().build()
    }
    public func enqueue(responseCallback: Callback):Unit {

    }

    public func cancel(): Unit {

    }

    public func isExecuted(): Bool {
        return false
    }
    public func isCanceled(): Bool {
        return false
    }
    public func timeout(): Timeout {
        return Timeout()
    }
    public func clone(): Call {
        return this
    }

    public func getResponseWithInterceptorChain(): Response {
       return Response.builder().build()
    }

    public static func newRealCall( client: OkHttpClient,  originalRequest: Request,  forWebSocket: Bool) {
       return RealCall()
    }

}

public class AsyncCall {
     public var callsPerHost: AtomicInt64 = AtomicInt64(0)
     private let  responseCallback: Callback
     private let  realCall: RealCall

     init(responseCallback: Callback, realCall: RealCall) {
        this.responseCallback = responseCallback
        this.realCall = realCall
     }

     func reuseCallsPerHostFrom( other: AsyncCall): Unit {
         this.callsPerHost = other.callsPerHost;
     }

     func get(): RealCall {
       return RealCall()
     }

     func host(): String {
        return ""
     }

     func executeOn() {
        spawn {
            execute()
        }
     }


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

public class Timeout{

}