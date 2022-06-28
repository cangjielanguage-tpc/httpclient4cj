/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkHttpClient class.
 */
package okhttp

/*
 * The interface is CallFactory
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
interface CallFactory {
     /*
      * The Function is newCall
      *
      * @param request of Request
      *
      * @return Type of Call
      * @since 0.29.3
      */
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

/**
 * The class is OkHttpClient
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class OkHttpClient {
     /* var member dispatcher type is Dispatcher */
     var dispatcher: Dispatcher
     /* var member interceptors type is ArrayList<Interceptor> */
     var interceptors: ArrayList<Interceptor>
     /* var member followRedirects type is Bool */
     var followRedirects: Bool


     /**
      * The Function is init constructor
      *
      * @param builder of OkHttpClientBuilder
      * @since 0.29.3
      */
     public init(builder: OkHttpClientBuilder) {
          this.dispatcher = builder.dispatcherBuild
          this.interceptors = builder.interceptorsBuild
          this.followRedirects = builder.followRedirectsBuild
     }
     /**
      * The Function is builder
      *
      * @return Type of OkHttpClientBuilder
      * @since 0.29.3
      */
     public static func builder(): OkHttpClientBuilder{
        return OkHttpClientBuilder()
     }

     /**
      * The Function is newCall
      *
      * @param request of Request
      *
      * @return Type of Call
      * @since 0.29.3
      */
     public func newCall(request: Request): Call {
          return RealCall.newRealCall(this, request, false)
     }
     /**
      * The Function is getFollowRedirects
      *
      * @return Type of Bool
      * @since 0.29.3
      */
     public func getFollowRedirects():Bool {
        return followRedirects
     }

}

