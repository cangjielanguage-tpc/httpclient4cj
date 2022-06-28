/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ResponseBuilder class.
 */
package okhttp
from net import http.*

/**
 * The class is ResponseBuilder inherited from Builder<Response>
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ResponseBuilder <: Builder<Response> {
   /* var member requestBuild type is Request */
   var requestBuild: Request = Request.builder().build()
   /* var member protocolBuild type is Protocol */
   var protocolBuild: Protocol = HTTP_1_0("http/1.0")
   /* var member codeBuild type is Int64 */
   var codeBuild: Int64 = -1
   /* var member messageBuild type is String */
   var messageBuild: String = ""
   /* var member headersBuild type is Header */
   var headersBuild: Header = Header()
   /* var member bodyBuild type is Option<ResponseBody> */
   var bodyBuild: Option<ResponseBody> = Option<ResponseBody> .None



   /**
    * The Function is request
    *
    * @param request of Request
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func request(request: Request): ResponseBuilder {
      this.requestBuild = request
      return this
   }

   /**
    * The Function is protocol
    *
    * @param protocol of Protocol
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func protocol(protocol: Protocol): ResponseBuilder {
      this.protocolBuild = protocol
      return this
   }

   /**
    * The Function is code
    *
    * @param code of Int64
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func code(code: Int64): ResponseBuilder {
      this.codeBuild = code
      return this
   }

   /**
    * The Function is message
    *
    * @param message of String
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func message(message: String): ResponseBuilder {
      this.messageBuild = message
      return this
   }
   /**
    * The Function is header
    *
    * @param name of String
    * @param value of String
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func header(name: String, value: String): ResponseBuilder {
      headersBuild.set(name, value)
      return this
   }

   /**
    * The Function is addHeader
    *
    * @param name of String
    * @param value of String
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func addHeader(name: String, value: String): ResponseBuilder {
      headersBuild.add(name, value)
      return this
   }

   /**
    * The Function is removeHeader
    *
    * @param name of String
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func removeHeader( name: String): ResponseBuilder {
      headersBuild.remove(name)
      return this
   }

   /**
    * The Function is body
    *
    * @param body of ResponseBody
    *
    * @return Type of ResponseBuilder
    * @since 0.29.3
    */
   public func body(body: ResponseBody): ResponseBuilder {
      this.bodyBuild = body
      return this
   }


   /**
    * The Function is build
    *
    * @return Type of Response
    * @since 0.29.3
    */
   public func build(): Response {
      return Response(this)
   }
}






