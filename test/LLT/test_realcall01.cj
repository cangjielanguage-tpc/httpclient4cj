// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main (){
    var realcall = RealCall()
    realcall.request()
    realcall.execute()
    realcall.cancel()
    realcall.isExecuted()
    realcall.isCanceled()
    realcall.timeout()
    realcall.clone()
    realcall.getResponseWithInterceptorChain()
    let client = OkHttpClient.builder().build()
    let originalRequest = Request.builder().build()
    RealCall.newRealCall(client, originalRequest, true)
    realcall.enqueue(Callbacks())
    return 0
}

public class Callbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{

    }
    public func onResponse(call: Call,  response: Response): Unit{

    }
}
