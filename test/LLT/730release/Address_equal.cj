// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from encoding import url.*
from std import collection.*


main() {
    let parseUrl = URL.parse("http://www.baidu.com/index.html")
    let parseUrl2 = URL.parse("http://www.jd.com/index.html")
    let parseUrl3 = parseUrl.resolveReference(parseUrl2)
    printlnURL(parseUrl)
    printlnURL(parseUrl2)
    printlnURL(parseUrl3)
    let arr  = ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()])
    let a1 = Address(parseUrl2, arr)
    let a2 = Address(parseUrl3, arr)
    if(a1 == a2) {
        return 0
    }
    return -1
}

func printlnURL(url: URL) {
    println("host = ${url.host}")
    println("path = ${url.path}")
    println("hostname = ${url.hostname()}")
    println("port = ${url.port()}")
    println("toString = ${url.toString()}")
}