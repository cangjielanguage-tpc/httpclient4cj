// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main

from encoding import url.*

main (){
     let s = URL.parse("http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello").hostName
     println(s)
     return 0
}

