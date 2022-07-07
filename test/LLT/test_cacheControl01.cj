// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from net import http.*

main (){
    var m = Header()           
        m.add("Accept-Encoding","gzip")
        m.add("Accept-Language","zh-CN")
        m.add("Access-Control-Request-Method","POST")
        m.add("content-type","application/json")
        m.add("Cache-Control","private")
        m.add("Cache-Control","no-cache")
        m.add("Cache-Control","public")
        m.add("Cache-Control","s-maxage=7200")
        m.add("Pragma","no-cache")

    var res = CacheControl.parse(m)

    println(res.toString())
    
    return 0
}