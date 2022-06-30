<p align="center">
<img src="./doc/assets/logo.png" width="50%" >
</p>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.30.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-91%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## <img alt="" src="./doc/assets/readme-icon-introduction.png" style="display: inline-block;" width=3%/>介绍

OkHttp 是一个高效的 HTTP 客户端, 代码参考: https://github.com/square/okhttp/tree/okhttp_3.14.x

### 特性 

- 🚀 支持HTTP/2，允许所有同一个主机地址的请求共享同一个socket连接

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
│   ├── Builder.cj
│   ├── Call.cj
│   ├── CallBack.cj
│   ├── ConnectInterceptor.cj
│   ├── Dispatcher.cj
│   ├── Interceptor.cj
│   ├── OkHttpClient.cj
│   ├── OkHttpClientBuilder.cj
│   ├── Protocol.cj
│   ├── Queue.cj
│   ├── Request.cj
│   ├── RequestBuilder.cj
│   └── Response.cj
│   └── ResponseBody.cj
│   └── ResponseBuilder.cj
│   └── RetryAndFollowUpInterceptor.cj
│   └── StatusLine.cj
│   └── Util.cj
│   └── transport.cj
└── test   
    ├── HLT
    ├── LLT
    └── UT
```

- `doc`是库的设计文档、提案、库的使用文档
- `src`是库源码目录
- `test`是存放测试用例，包括HLT用例、LLT 用例和UT用例

### 接口说明

主要是核心类和成员函数说明,详情见 [API](./doc/api.md)

#### class OkHttpClient

##### func builder

成员函数功能描述

```cangjie
public static func builder(): OkHttpClientBuilder
```

## <img alt="" src="./doc/assets/readme-icon-compile.png" style="display: inline-block;" width=3%/>编译执行

### 编译

编译描述和具体shell命令

```shell
cpm update
cpm build
```

### 示例

暂无

## <img alt="" src="./doc/assets/readme-icon-contribute.png" style="display: inline-block;" width=3%/>参与贡献

主要写参与贡献的人以及个人主页链接

[@guo_tingtingtekla](https://gitee.com/guo_tingtingtekla)[@luoyukai4](https://gitee.com/luoyukai4)