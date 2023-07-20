// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*

//不支持http1.0
main (){
    try{
        let client = HttpClient.builder()
        .protocols(ArrayList<String>([httpclient4cj.Protocol.get("HTTP/1.0").toString()])).build()
    }catch (e:Exception) {
        return 0
    }
    return 1
}