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
        ArrayList<String>()).build()
    }catch(e: Exception) {
        return 0
    }
    return 1
}