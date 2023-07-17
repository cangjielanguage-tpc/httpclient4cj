// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from std import collection.*

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