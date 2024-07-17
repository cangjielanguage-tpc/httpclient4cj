// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.io.*
import httpclient4cj
import httpclient4cj.*
import std.time.*

import std.collection.*

main() {
    try{
        let client: HttpClient=
        HttpClient.builder()
        .protocols(
        ArrayList<String>([httpclient4cj.Protocol.get("HTTP/2.0").toString()])).build()
    }catch(e: Exception) {
        return 0
    }
    return 1
}