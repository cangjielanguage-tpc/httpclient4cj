package okhttp

public class ConnectInterceptor<: Interceptor {
    public let client: OkHttpClient

    public init (client: OkHttpClient) {
        this.client = client;
    }

    public func intercept(chain: Chain): Response {

       return Response.builder().build()

    }



}