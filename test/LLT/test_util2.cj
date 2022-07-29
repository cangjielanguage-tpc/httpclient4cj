// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*

main() {
    let url1 = URL.parse("http://10.100.90.109:8079")
    let url2 = URL.parse("http://10.100.90.109:8079")
    let url3 = URL.parse("http://10.100.90.109:8079")

    if(!Util.sameConnection(url1, url2) ||
       !Util.sameConnection(url1, url3) ||
       Util.getRequestMethod("PUT").toString() != "PUT" || 
       Util.getRequestMethod("POST").toString() != "POST" || 
       Util.getRequestMethod("HEAD").toString() != "HEAD" || 
       Util.getRequestMethod("PATCH").toString() != "PATCH" || 
       Util.getRequestMethod("TRACE").toString() != "TRACE" || 
       Util.getRequestMethod("DELETE").toString() != "DELETE" || 
       Util.getRequestMethod("CONNECT").toString() != "CONNECT" || 
       Util.getRequestMethod("OPTIONS").toString() != "OPTIONS" 
    ) {
        return -1
    }
    
    return 0
}

