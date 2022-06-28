/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the OkHttpClientBuilder class.
 */
package okhttp

/**
 * The class is OkHttpClientBuilder inherited from Builder<OkHttpClient>
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class OkHttpClientBuilder <: Builder<OkHttpClient> {
     /* var member dispatcherBuild type is Dispatcher */
     var dispatcherBuild: Dispatcher = Dispatcher()
     /* var member interceptorsBuild type is ArrayList<Interceptor> */
     var interceptorsBuild: ArrayList<Interceptor> = ArrayList<Interceptor>()
     /* var member followRedirectsBuild type is Bool */
     var followRedirectsBuild: Bool = false

     /**
      * The Function is addInterceptor
      *
      * @param interceptor of Interceptor
      *
      * @return Type of OkHttpClientBuilder
      * @since 0.29.3
      */
     public func addInterceptor(interceptor: Interceptor): OkHttpClientBuilder {
         interceptorsBuild.add(interceptor)
         return this
     }

     /**
      * The Function is build
      *
      * @return Type of OkHttpClient
      * @since 0.29.3
      */
     public func build(): OkHttpClient {
          return OkHttpClient(this)
     }
}

