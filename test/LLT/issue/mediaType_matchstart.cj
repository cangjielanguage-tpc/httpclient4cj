// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*
main (){
     match(MediaType.parse("#$%^@#&*$/#$%^@#&*$; charset=utf-8")) {
        case Some(v) => return 1
        case None => return 0
     }
}