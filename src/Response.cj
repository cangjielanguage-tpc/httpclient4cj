package okhttp
from net import http.*

public class Response {
      var request: Request
      var protocol: Protocol
      var code: Int64
      var message: String
      var headers: Header
      var body: Option<ResponseBody>



      public init(builder: ResponseBuilder){
         this.request = builder.requestBuild
         this.protocol = builder.protocolBuild
         this.code = builder.codeBuild
         this.message = builder.messageBuild
         this.headers = builder.headersBuild
         this.body = builder.bodyBuild

      }

      public func getRequest(): Request {
         return request
      }

      /**
      * Returns the HTTP protocol, such as {@link Protocol#HTTP_1_1} or {@link Protocol#HTTP_1_0}.
      */
      public func getProtocol(): Protocol {
      return protocol
      }

      /** Returns the HTTP status code. */
      public func getCode(): Int64 {
         return code
      }

      /**
      * Returns true if the code is in [200..300), which means the request was successfully received,
      * understood, and accepted.
      */
      public func isSuccess(): Bool {
         return code >= 200 && code < 300
      }

      /** Returns the HTTP status message. */
      public func getMessage(): String {
         return message
      }

      public func getHeaders(name: String): ArrayList<String> {
        // return headerss.values(name) //todo
        return ArrayList<String>()
      }

      public func getHeader(name: String): String {
         return getHeader(name, "")
      }

      public func getHeader(name: String, defaultValue: String): String {
         var result: String = headers.get(name).getOrThrow()
         return if(!result.isEmpty()) { result } else { defaultValue }
      }

      public func getHeaders(): Header {
         return headers
      }

      public func getBody(body: ResponseBody) {
         this.body = body
      }

      /** Returns true if this response redirects to another resource. */
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
      * Closes the response body. Equivalent to {@code body().close()}.
      *
      * <p>It is an error to close a response that is not eligible for a body. This includes the
      * responses returned from {@link #cacheResponse}, {@link #networkResponse}, and {@link
      * #priorResponse()}.
      */
      public func close() {
         match (body) {
            case Some(v) => v.close()
            case None => throw Exception("response is not eligible for a body and must not be closed")
         }
      }

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

      public static func builder(): ResponseBuilder {
         return ResponseBuilder()
      }

}






