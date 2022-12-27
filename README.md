<div align="center">
<h1>OkHttp</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.35.6-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-85.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>介绍

OkHttp 是一个高效的 HTTP 客户端, 代码参考: https://github.com/square/okhttp/tree/parent-3.14.9

### 特性

- 🚀 支持HTTP/2，允许所有同一个主机地址的请求共享同一个 socket 连接

- 🌍 连接池减少请求延时

- 💪 缓存响应内容，避免一些完全重复的请求

### 路线

<p align="center">
<img src="./doc/assets/milestone.png" width="100%" >
</p>

## <img alt="" src="./doc/assets/readme-icon-framework.png" style="display: inline-block;" width=3%/> 软件架构

### 架构图

<p align="center">
<img src="./doc/assets/framework.PNG" width="60%" >
</p>

### 源码目录

```shell
.
├── README.md
├── doc
│   ├── assets
│   ├── cjcov     
│   ├── api.md  
│   ├── design.md  
│   ├── proposal.md
│   └── xxx_lib.md 
├── lib
│   └── libdns.so
├── src
│   └── okhttp
│      ├── address.cj
│      ├── bridge_interceptor.cj
│      ├── cache_control.cj
│      ├── cache_control_builder.cj
│      ├── call.cj
│      ├── call_back.cj
│      ├── call_server_interceptor.cj
│      ├── connect_interceptor.cj
│      ├── cookie.cj
│      ├── cookie_jar.cj
│      ├── dispatcher.cj
│      ├── error_code.cj
│      ├── event_listener.cj
│      ├── exception.cj
│      ├── exchange_codec.cj
│      ├── exchange_codec2.cj
│      ├── exchange_finder.cj
│      ├── form_body.cj
│      ├── hpack_config.cj
│      ├── hpack_decoder.cj
│      ├── hpack_encoder.cj
│      ├── hpack_tables.cj
│      ├── http2_connection.cj
│      ├── http2_stream.cj
│      ├── http2_writer.cj
│      ├── http2_reader.cj
│      ├── http_method.cj
│      ├── huffman.cj
│      ├── huffman_util.cj
│      ├── chain.cj
│      ├── interfaces.cj
│      ├── multipart_body.cj
│      ├── ok_buffer.cj
│      ├── ok_gzip_source.cj
│      ├── ok_http_client.cj
│      ├── ok_http_client_builder.cj
│      ├── ok_socket.cj
│      ├── protocol.cj
│      ├── queue.cj
│      ├── real_connection.cj
│      ├── real_connection_pool.cj
│      ├── request.cj
│      ├── request_body.cj
│      ├── request_builder.cj
│      ├── request_line.cj
│      ├── response.cj
│      ├── response_body.cj
│      ├── response_builder.cj
│      ├── retry_and_follow_up_interceptor.cj
│      ├── route.cj
│      ├── route_database.cj
│      ├── route_selector.cj
│      ├── settings.cj
│      ├── sink.cj
│      ├── socket_ffi.cj
│      ├── source.cj
│      ├── status_line.cj
│      ├── transmitter.cj
│      └── util.cj
└── test   
    ├── HLT
    ├── LLT
    └── UT
```
- `lib`依赖 c 库的dns解析接口的动态链接文件
- `doc`是库的设计文档、提案、库的使用文档、LLT 覆盖报告 ( 由于未支持服务端的对接,部分拦截器连接后处理逻辑暂时无法覆盖)
- `src`是库源码目录
- `test`是存放测试用例，包括 HLT 用例、LLT 用例和 UT 用例

### 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/api.md)

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/> 编译执行

### 编译

编译描述和具体shell命令

```shell
cpm update
cpm build
```

### 示例

注意：以下示例若在本地不成功，可能是 url 地址请求失败，请换成实际可用地址。

```
from okhttp import okhttp.*
from net import http.*
from std import collection.*
from encoding import url.*
from net import tls.*

main (){
    let client = OkHttpClient.builder()
                        .addNetworkInterceptor(MyInterceptor())
                        .protocols(ArrayList<String>([Protocol.get("HTTP/2.0").toString(),Protocol.get("HTTP/1.1").toString()]))
                        .build()

    let request: okhttp.Request = okhttp.Request
                        .builder()
                        .url("http://36.152.44.95/index.html")
                        .header(Header())
                        .header("User-Agent", "OkHttp-Example")
                        .build()
    let response: okhttp.Response = client.newCall(request).execute()
    return 0
}

class MyInterceptor<: Interceptor {
    public func intercept(chain: Chain): okhttp.Response {
        let conn = chain.getConnection().getOrThrow()
        conn.getRoute()
        let add = Address(URL.parse("http://36.152.44.95/index.html"),
                            ArrayList<String>([Protocol.get("H2_PRIOR_KNOWLEDGE").toString()]),
                            Option<TlsClientConfig>.None
                        )
        add.getTlsConfig()
        conn.noExchanges()
        println(conn.isMultiplexed())
        conn.cancel()
        let request: okhttp.Request = chain.getRequest()
        let header: Header = request.getHeaders()
        let c = request.getCacheControl() ?? CacheControl.parse(header)
        println(c.toString())
        return okhttp.Response.builder().build()
    }
}
```

执行结果

```
false
no-cache, no-store, max-age=0, s-maxage=0, private, public, must-revalidate, max-stale=0, min-fresh=0, only-if-cached, no-transform, immutable

```

#### chunked分块传输请求
```

from okhttp import okhttp.*
from std import collection.*
from net import http.*
from std import io.*
from std import socket.*

var port: UInt16 = 0
main() {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:${port}/1234")
                                    .method("POST", body: MyRequestBody())
                                    .build()
    let response: okhttp.Response = client.newCall(request).execute()
    println(response.toString())
    if(response.getBody()?.isClosed() ?? true) {
        return 1
    } else {
        response.getBody()?.close()
        return 0
    }
}

func serve(){
    let hd = http.Route()
    hd.handle("/1234", { rws: http.ResponseWriteStream, req: http.Request =>
        println(String.fromUtf8(req.readToEnd()))
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}


class MyRequestBody <:RequestBody {
    public func contentType(): String {
        return "application/json"
    }
    
    //声明的getContentLength -1，客户端拦截器默认添加"Transfer-Encoding", "chunked"头,使用ChunkedSink读取body
    public func getContentLength(): Int64 {
        return -1
    }
    
    public func writeTo(sink: Sink): Unit {
        //每次调用write都会产生一个传输块
        sink.write("hello".toUtf8Array())
        sink.write("world".toUtf8Array())
    }

    public func get(): InputStream {
        return ByteArrayStream()

    }

}
```

运行结果
```
helloworld
Response{protocol=http/1.1, code=200, message=OK, url=http://127.0.0.1:38621/1234}
```
## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

主要写参与贡献的人以及个人主页链接

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。