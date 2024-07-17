// DEPENDENCE: ./body.text
// DEPENDENCE: ./body2.text
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import std.collection.*
import net.http.*
import std.io.*
import std.socket.*
import std.fs.*
import std.sync.sleep
import std.time.*

var port: UInt16 = 0
main() {
    serve()
    let body = RealRequestBody.create(
        MediaType.get("application/json"), 
        File("./body.text", OpenOption.Open(true, false))
    )
    let body2 = RealRequestBody.create(
        MediaType.get("application/json"),
        File("./body2.text", OpenOption.Open(true, false))
    )
    let mu = MultipartBody.builder()
        .addFormDataPart("name", "lyk")
        .addFormDataPart("age", "18")
        .addFormDataPart("file1", "body.text", body)
        .addFormDataPart("file2", "body2.text", body2)
        .build()
    let client: HttpClient = HttpClient.builder().build()
    let request: httpclient4cj.Request =
        httpclient4cj.Request.builder().url("http://127.0.0.1:${port}/1234").method("POST", body: mu).build()
    let response: httpclient4cj.Response = client.newCall(request).execute()
    println(response.toString())
    if (response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
        return 0
    }
}

func serve() {
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234",
        {
        httpContext =>
        println(StringReader(httpContext.request.body).readToEnd())
        return
    })
    spawn {server.serve()}
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}
