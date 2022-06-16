package okhttp

from std import  collection.*

public interface Interceptor {
   func intercept(chain: Chain): Response
}

public class Chain {
    private var interceptors: ArrayList<Interceptor>
    private var calls: Int64 = 0
    private var index: Int64
    private var request: Request
    private var call: Call

    public init(interceptors: ArrayList<Interceptor>, index:Int64, request: Request,  call: Call ){
        this.index = index
        this.request = request
        this.call = call
        this.interceptors = interceptors
    }



    public func getRequest(): Request {
        return request
    }

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

    public func getCall(): Call {
        return call
    }

    func connectTimeoutMillis(): Int64 {
        return 1
    }

    func withConnectTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }

    func readTimeoutMillis(): Int64 {
        return 1
    }

    func withReadTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }

    func writeTimeoutMillis(): Int64 {
        return 1
    }

    func withWriteTimeout(timeout: Int64,  unit: TimeUnit): Chain {
        return this
    }
}

public class TimeUnit {


}