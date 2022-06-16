package okhttp

public class OkHttpClientBuilder <: Builder<OkHttpClient> {
     var dispatcherBuild: Dispatcher = Dispatcher()
     var interceptorsBuild: ArrayList<Interceptor> = ArrayList<Interceptor>()
     var followRedirectsBuild: Bool = false

     public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder {
         interceptorsBuild.add(interceptor)
         return this
     }

     public func build(): OkHttpClient {
          return OkHttpClient(this)
     }
}

