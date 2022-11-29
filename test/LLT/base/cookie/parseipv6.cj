// EXEC: cjc %import-path %L %l %f
// EXEC: ./main


from okhttp import okhttp.*
from encoding import url.*
from net import http.*

//测试domain 为 ipv6
main() {
    let c = CookieUtil.parse(URL.parseRequestURI("http://[Ff00::b465:310d]/foo/bar/baz"),
        "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=Ff00::b465:310d")
    println(c.getOrThrow().toString())
    match (c) {
        case Some(v) => return 0
        case None => return 1
    }
}