// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

main (){
    let client = OkHttpClient.builder().build()
    let originalRequest = Request.builder().build()
    let responseCallback = Callbacks()
    let realCall = client.newCall(originalRequest)
    let responseCallback1 = Callbacks()
    let realCall1 = client.newCall(originalRequest)
    responseCallback1.onFailure(realCall1, Exception())
    return 0
}

public class Callbacks <: Callback {

    public func onFailure(call: Call,  e: Exception): Unit{

    }
    public func onResponse(call: Call,  response: Response): Unit{

    }
}
