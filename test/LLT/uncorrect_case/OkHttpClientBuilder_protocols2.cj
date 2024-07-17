// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.http.*
import std.collection.*
import encoding.url.*
import net.tls.*

//不支持空数组
main (){
    try{
        let client = HttpClient.builder()
        .protocols(ArrayList<String>([])).build()
    }catch (e:Exception) {
        return 0
    }
    return 1
}