// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.http.*

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

    if(res.toString() == "no-cache, no-store, max-age=0, s-maxage=7200, private, public, must-revalidate, max-stale=0, min-fresh=0, only-if-cached, no-transform, immutable") {
        return -1
    }
    
    return 0
}