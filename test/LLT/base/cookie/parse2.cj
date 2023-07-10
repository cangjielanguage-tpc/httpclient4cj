// EXEC: cjc %import-path %L %l %f
// EXEC: ./main


from okhttp import okhttp.*
from encoding import url.*
from net import http.*

//覆盖设置cookie对报文的影响，setCookie HttpOnly
main() {
    let c = CookieUtil.parse(URL.parse("http://180.101.49.13/foo/bar/baz"),
        "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=180.101.49.13")
    println(c.getOrThrow().toString())

}