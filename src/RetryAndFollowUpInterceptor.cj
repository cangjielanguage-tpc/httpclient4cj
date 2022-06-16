package okhttp

from encoding import url.*
from net import http.HttpStatusCode

public class RetryAndFollowUpInterceptor<: Interceptor {
    private let  client: OkHttpClient

    public init(client: OkHttpClient) {
        this.client = client;
    }

    /*max redirect count*/
    private static let  MAX_FOLLOW_UPS: Int64 = 20;

    public func intercept(chain: Chain): Response {
        let request: Request = chain.getRequest()
        while (true) {
            var response: Response
            try {
                //invoke next interceptor
               response =  chain.proceed(request)
            } catch (e: Exception) {
                //TODO confirm redirect condition
            } finally {

            }
            match (followUpRequest(response)) {
                case Some(r)  => return response
                case _ => return response
            }
        }
        return Response.builder().build()
    }


    func followUpRequest(response: Response): Option<Request> {
        let code: Int64 = response.code
        let method: String = response.getRequest().getMethod()
        match (code) {
            case 307 | 308 => {
                    // 307,308 If this is not a GET or HEAD request, the browser disables automatic redirection
                    if (method == "GET" || method == "HEAD") {
                        return Option<Request>.None
                    }
                    return redirectRequest(response)
                }
            case 300 | 301 |
                302 | 303 =>{
                    return redirectRequest(response)
                }
            case _ => return Option<Request>.None
        }


    return Option<Request>.None

    }

    func redirectRequest(response: Response): Option<Request> {
        if (!client.getFollowRedirects()) {
            return Option<Request>.None
        }
        let location: String = response.getHeader("Location", "")
        if (location == "") {
            return Option<Request>.None
        }
         return Option<Request>.None

    }
}