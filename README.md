<p align="center">
<img src="./doc/assets/logo.png" width="50%" >
</p>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.2-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.30.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-82%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>介绍

OkHttp 是一个高效的 HTTP 客户端, 代码参考: https://github.com/square/okhttp/tree/okhttp_3.14.x

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
├── src
│   ├── Address.cj
│   ├── BridgeInterceptor.cj
│   ├── Builder.cj
│   ├── cache_control_builder.cj
│   ├── cache_control.cj
│   ├── Call.cj
│   ├── CallBack.cj
│   ├── CallServerInterceptor.cj
│   ├── ConnectInterceptor.cj
│   ├── Dispatcher.cj
│   ├── exchangeCodec.cj
│   ├── ExchangeFinder.cj
│   ├── Interceptor.cj
│   ├── OkHttpClient.cj
│   ├── OkHttpClientBuilder.cj
│   ├── Protocol.cj
│   ├── Queue.cj
│   ├── RealConnection.cj
│   ├── Request.cj
│   ├── RequestBody.cj
│   ├── RequestBuilder.cj
│   └── Response.cj
│   └── ResponseBody.cj
│   └── ResponseBuilder.cj
│   └── RetryAndFollowUpInterceptor.cj
│   └── StatusLine.cj
│   └── Util.cj
│   └── Transmitter.cj
└── test   
    ├── HLT
    ├── LLT
    └── UT
```

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

```
from okhttp import okhttp.*
from net import http.*
from std import io.*
from std import time.*
from std import socket.*

var port: UInt16 = 8888
main() {
    spawn {
        serve()
    }
    sleep(1000*1000*1000)

    let cache: CacheControl = CacheControl.builder()
                                .maxAge(Duration.second(1000))
                                .build()
    let client: OkHttpClient= OkHttpClient.builder().build()
    let request: okhttp.Request = okhttp.Request.builder()
                                    .url("http://127.0.0.1:50066/cangjie_test-1.0-SNAPSHOT/hello")
                                    .method("GET")
                                    .cacheControl(cache)
                                    .build()
    let call = client.newCall(request)
    let response: okhttp.Response = call.execute()

    println(response.getBody().getOrThrow().getSource().toString())
    return 0
}

func serve(){
    let hd = http.Route()
    hd.handle("/index", { rws: http.ResponseWriteStream, req: http.Request =>
        let resp = "Hello from /red".toUtf8Array()
        rws.write(resp)
        return
    })
    let server = http.Server(hd)
    let socket = socket.SocketServer(SocketNet.TCP, "0.0.0.0", port)
    port = socket.port
    server.serve(socket)
}
```

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/> 参与贡献

主要写参与贡献的人以及个人主页链接

[@guo_tingtingtekla](https://gitee.com/guo_tingtingtekla)[@luoyukai4](https://gitee.com/luoyukai4)