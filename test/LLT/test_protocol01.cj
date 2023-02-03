// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*
main (){
    let str1 = Protocol.get("http/1.0")
    let index1 = str1.toString()
    let str2 = Protocol.get("http/1.1")
    let index2 = str2.toString()

    let str4 = Protocol.get("h2")
    let index4 = str4.toString()
    let str5 = Protocol.get("h2_prior_knowledge")
    let index5 = str5.toString()
    try {
        let str7 = Protocol.get("ccc")
        let index7 = str7.toString()
    } catch(e: Exception) {
        println("case pass")
    }
    return 0
}