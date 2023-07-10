// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from encoding import url.*

main (){
     let s = URL.parse("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello").hostName
     println(s)
     return 0
}

