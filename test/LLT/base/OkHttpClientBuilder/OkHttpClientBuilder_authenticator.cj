// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*
import std.collection.*
import std.socket.*

main (){
    let client: HttpClient= HttpClient.builder()
        .followSslRedirects(false)
        .authenticator({route: Option<Route>, response: Response => Option<Request>.None}).build()
    client.getAuthenticator()
    if(client.getFollowSslRedirects() == true)  {
        return 1
    }

    return 0
}
