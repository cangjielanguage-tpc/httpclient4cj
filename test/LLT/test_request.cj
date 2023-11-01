// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import collection.*
from std import sync.sleep
from std import time.*

var port: UInt16 = 0
main(){
  spawn {
    serve()
  }
  sleep(Duration.second*2)
 let mUrl = "http://0.0.0.0:${port}/1241"
 var jsonStr = ##"{"name":"Tom","age":"18","version":"0.1.1"}"##
 let requestBody:Option<RequestBody> = Option<RequestBody>.Some(
    RealRequestBody.create(MediaType.get("application/json"), jsonStr.toArray()))
 var proArray = ArrayList<String>()
 proArray.append("http/1.1")
  let header: Header = Header()
  header.add("aaa", "application/json")
  header.add("aaa", "application2/json")
 let client = HttpClient.builder().protocols(proArray).build()
 let request: httpclient4cj.Request = httpclient4cj.Request.builder().url(mUrl).header(header).method("POST",body:requestBody).build()
 let response: httpclient4cj.Response = client.newCall(request).execute()
 match(response.getBody()){
    case Some(v) =>
    print("true成功")
    v.close()
    case _ =>
    print("false失败")
    ()
 }
 ()
}

 public func serve(){

    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1241", { httpContext =>
      let resp = "Hello from /red".toArray()
      httpContext.responseBuilder.body(resp)
      return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
  }