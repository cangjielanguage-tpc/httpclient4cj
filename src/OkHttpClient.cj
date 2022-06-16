package okhttp

interface CallFactory {
     func newCall(request: Request): Call
}

/*
 * http://user:pass@www.example.com:80/dir/index.html?uid=1#ch1
 * 
 * client: OkHttpClient= OkHttpClient.builder()
 *     .addInterceptor(HttpLoggingInterceptor())
 *     .build()
 * request: Request = Request.builder()
 *   .url("http://www.publicobject.com/helloworld.txt")
 *   .header("User-Agent", "OkHttp Example")
 *   .build()
 * response: Response = client.newCall(request).execute()
 * response.body().close()
 */
 
public class OkHttpClient {
     var dispatcher: Dispatcher
     var interceptors: ArrayList<Interceptor>
     var followRedirects: Bool


     public init(builder: OkHttpClientBuilder) {
          this.dispatcher = builder.dispatcherBuild
          this.interceptors = builder.interceptorsBuild
          this.followRedirects = builder.followRedirectsBuild
     }
     public static func builder(): OkHttpClientBuilder{
        return OkHttpClientBuilder()
     }
     
     public func newCall(request: Request): Call {
          return RealCall.newRealCall(this, request, false)
     }
     public func getFollowRedirects():Bool {
        return followRedirects
     }

}

