// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*
from std import fs.*

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
