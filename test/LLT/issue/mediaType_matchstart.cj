// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std. collection.*
main (){
     match(MediaType.parse("#$%^@#&*$/#$%^@#&*$; charset=utf-8")) {
        case Some(v) => return 1
        case None => return 0
     }
}