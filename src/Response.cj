/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Response class.
 */
package okhttp
from net import http.*

/**
 * The class is Response
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Response {
      /* var member request type is Request */
      var request: Request
      /* var member protocol type is Protocol */
      var protocol: Protocol
      /* var member code type is Int64 */
      var code: Int64
      /* var member message type is String */
      var message: String
      /* var member headers type is Header */
      var headers: Header
      /* var member body type is Option<ResponseBody> */
      var body: Option<ResponseBody>



      /**
       * The Function is init constructor
       *
       * @param builder of ResponseBuilder
       * @since 0.29.3
       */
      public init(builder: ResponseBuilder){
         this.request = builder.requestBuild
         this.protocol = builder.protocolBuild
         this.code = builder.codeBuild
         this.message = builder.messageBuild
         this.headers = builder.headersBuild
         this.body = builder.bodyBuild

      }

      /**
       * The Function is getRequest
       *
       * @return Type of Request
       * @since 0.29.3
       */
      public func getRequest(): Request {
         return request
      }

      /**
       * The Function is getProtocol
       *
       * @return Type of Protocol
       * @since 0.29.3
       */
      public func getProtocol(): Protocol {
      return protocol
      }


      /**
       * The Function is getCode
       *
       * @return Type of Int64
       * @since 0.29.3
       */
      public func getCode(): Int64 {
         return code
      }

      /**
       * The Function is isSuccess
       *
       * @return Type of Bool
       * @since 0.29.3
       */
      public func isSuccess(): Bool {
         return code >= 200 && code < 300
      }


      /**
       * The Function is getMessage
       *
       * @return Type of String
       * @since 0.29.3
       */
      public func getMessage(): String {
         return message
      }

      /**
       * The Function is getHeaders
       *
       * @param name of String
       *
       * @return Type of ArrayList<String>
       * @since 0.29.3
       */
      public func getHeaders(name: String): ArrayList<String> {
        // return headerss.values(name) //todo
        return ArrayList<String>()
      }

      /**
       * The Function is getHeader
       *
       * @param name of String
       *
       * @return Type of String
       * @since 0.29.3
       */
      public func getHeader(name: String): String {
         return getHeader(name, "")
      }

      /**
       * The Function is getHeader
       *
       * @param name of String
       * @param defaultValue of String
       *
       * @return Type of String
       * @since 0.29.3
       */
      public func getHeader(name: String, defaultValue: String): String {
         var result: String = headers.get(name).getOrThrow()
         return if(!result.isEmpty()) { result } else { defaultValue }
      }

      /**
       * The Function is getHeaders
       *
       * @return Type of Header
       * @since 0.29.3
       */
      public func getHeaders(): Header {
         return headers
      }

      /**
       * The Function is getBody
       *
       * @param body of ResponseBody
       * @since 0.29.3
       */
      public func getBody(body: ResponseBody) {
         this.body = body
      }

      /**
       * The Function is isRedirect
       *
       * @return Type of Bool
       * @since 0.29.3
       */
      public func isRedirect(): Bool {
         if(code == StatusLine.HTTP_PERM_REDIRECT ||
            code == StatusLine.HTTP_TEMP_REDIRECT ||
            code == StatusLine.HTTP_MULT_CHOICE ||
            code == StatusLine.HTTP_MOVED_PERM ||
            code == StatusLine.HTTP_MOVED_TEMP ||
            code == StatusLine.HTTP_SEE_OTHER
            ) {
            return true
         } else {
            return false
         }

      }

      /**
       * The Function is close
       *
       * @since 0.29.3
       */
      public func close() {
         match (body) {
            case Some(v) => v.close()
            case None => throw Exception("response is not eligible for a body and must not be closed")
         }
      }

      /**
       * The Function is toString
       *
       * @return Type of String
       * @since 0.29.3
       */
      public func toString(): String {
         return "Response{protocol="
            + protocol.toString()
            + ", code="
            + code.toString()
            + ", message="
            + message
            + ", url="
            + request.getUrl().toString()
            + "}"
      }

      /**
       * The Function is builder
       *
       * @return Type of ResponseBuilder
       * @since 0.29.3
       */
      public static func builder(): ResponseBuilder {
         return ResponseBuilder()
      }

}






