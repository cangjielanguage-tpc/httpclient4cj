// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*

//不支持空数组
main (){
    try{
        let client = OkHttpClient.builder()
        .protocols(ArrayList<String>([])).build()
    }catch (e:Exception) {
        return 0
    }
    return 1
}