package okhttp
from net import http.*

public class ResponseBuilder <: Builder<Response> {
   var requestBuild: Request = Request.builder().build()
   var protocolBuild: Protocol = HTTP_1_0("http/1.0")
   var codeBuild: Int64 = -1
   var messageBuild: String = ""
   var headersBuild: Header = Header()
   var bodyBuild: Option<ResponseBody> = Option<ResponseBody> .None



   public func request(request: Request): ResponseBuilder {
      this.requestBuild = request
      return this
   }

   public func protocol(protocol: Protocol): ResponseBuilder {
      this.protocolBuild = protocol
      return this
   }

   public func code(code: Int64): ResponseBuilder {
      this.codeBuild = code
      return this
   }

   public func message(message: String): ResponseBuilder {
      this.messageBuild = message
      return this
   }
   /**
    * Sets the header named {@code name} to {@code value}. If this request already has any headers
    * with that name, they are all replaced.
    */
   public func header(name: String, value: String): ResponseBuilder {
      headersBuild.set(name, value)
      return this
   }

   public func addHeader(name: String, value: String): ResponseBuilder {
      headersBuild.add(name, value)
      return this
   }

   public func removeHeader( name: String): ResponseBuilder {
      headersBuild.remove(name)
      return this
   }

   public func body(body: ResponseBody): ResponseBuilder {
      this.bodyBuild = body
      return this
   }


   public func build(): Response {
      return Response(this)
   }
}






