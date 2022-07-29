// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*

from net import http.*
from std import io.*
from std import time.*
from std import socket.*
from encoding import url.*


main() {
    let head: http.Header = Header()
    head.add("content-type", "application/json") 
    head.add("content-type2", "application2/json")

    let body: okhttp.ResponseBody = okhttp.ResponseBody()
    let preResponse: okhttp.Response = okhttp.Response.builder()
                                    .header(head)
                                    .build()
    let response: okhttp.Response = okhttp.Response.builder()
                                    .prevResponse(preResponse)
                                    .header(head)
                                    .body(body)
                                    .build()
    
    if(response.getPrevResponse().getOrThrow().toString() != "Response{protocol=http/1.1, code=-1, message=, url=}") {
        return -1
    }
    return 0
}
