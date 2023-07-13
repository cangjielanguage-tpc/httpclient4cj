// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import collection.*
from std import socket.*

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
