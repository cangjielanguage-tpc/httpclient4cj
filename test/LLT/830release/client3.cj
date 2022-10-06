// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from std import collection.*

main() {
    try{
        let client: OkHttpClient=
        OkHttpClient.builder()
        .protocols(
        ArrayList<String>([Protocol.get("h2_prior_knowledge").toString(),
         Protocol.get("HTTP/1.1").toString()])).build()
    }catch(e: Exception) {
        return 0
    }
    return 1
}