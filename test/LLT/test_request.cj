// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import collection.*

var port: UInt16 = 0
main(){
  spawn {
    serve()
  }
  sleep(1000*1000*1000*2)
 let mUrl = "http://0.0.0.0:${port}/1241"
 var jsonStr = ##"{"name":"Tom","age":"18","version":"0.1.1"}"##
 let requestBody:Option<RequestBody> = Option<RequestBody>.Some(RealRequestBody.create("json",jsonStr.toUtf8Array()))
 var proArray = ArrayList<String>()
 proArray.append("http/1.1")
  let header: http.Header = Header()
  header.add("aaa", "application/json")
  header.add("aaa", "application2/json")
 let client = OkHttpClient.builder().protocols(proArray).build()
 let request: okhttp.Request = okhttp.Request.builder().url(mUrl).header(header).method("POST",body:requestBody).build()
 let response: okhttp.Response = client.newCall(request).execute()
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

    let hd = http.Route()
    hd.handle("/1241", { rws: http.ResponseWriteStream, req: http.Request =>
      let resp = "Hello from /red".toUtf8Array()
      rws.write(resp)
      return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
  }