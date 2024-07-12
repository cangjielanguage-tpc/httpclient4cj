# Changelog

## 0.0.5

- 适配cjc34.3版本
- 支持http2协议,与http2库强依赖解耦
- 提供http2相关接口 用于单独调用
- 支持cookie解析 和 cookiejar的用户自定义使用
- 提供更简单的请求方式接口
- 支持multiPartBody
- 支持formBody
- 支持chunked传输
- 添加dns解析的缓存
- 适配cjc35.6版本
- 添加mediaType
- 添加请求tag标签
- 添加事件监听器接口
- 优化性能

## 0.0.4

- 支持多次重定向
- 支持默认添加gzip的请求内容
- 支持tls的连接
- 修改requestBody 以及 ResponseBody 使用okio风格的source 以及 sink接口
- 添加客户端鉴权接口

## 0.0.3

- 适配cjc 0.30.4
- dns解析能力
- 加入连接池，实现连接复用

## 0.0.2

- 适配http2，实现异步请求与连接超时功能。

## 0.0.1

- 搭建基本框架，调通http1.1，实现同步请求。
- 适配cjc 0.29.3
