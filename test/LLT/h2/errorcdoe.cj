// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.http.*
import std.collection.*
import encoding.url.*
import net.tls.*
import std.fs.*

main (){
   var count = 0
   for(i in 0..15) {
        match(ErrorCode.fromHttp2(i)) {
            case Some(v) =>
                v.getCode()
                v.toString()
            case None => count++
        }

    }
    if (count ==4 ) {
        return 0
    } else {
        return 1
    }
}
