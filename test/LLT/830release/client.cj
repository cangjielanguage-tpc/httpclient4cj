// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*


main() {
    try{
        let client: OkHttpClient=
        OkHttpClient.builder().tlsConfig("").build()
    }catch(e: Exception) {
        return 1
    }
    return 0
}