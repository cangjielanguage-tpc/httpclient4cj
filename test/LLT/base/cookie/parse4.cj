// EXEC: cjc %import-path %L %l %f
// EXEC: ./main


from httpclient4cj import httpclient4cj.*
from encoding import url.*
from net import http.*

//覆盖设置cookie对报文的影响，expires year>=70 自动补全
main() {
    let c = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"),
        "acw_tc=0a324fb516657393236678577e76052a825b3fafab5db4e52bcc6530fe5a0e; expires=Sun, 13 Oct 70 08:44:48 GMT; path=/;HttpOnly;Max-Age=1800")
    println(c.getOrThrow().toSetCookieString())

}