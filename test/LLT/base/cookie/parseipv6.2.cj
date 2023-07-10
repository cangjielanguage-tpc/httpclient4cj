// EXEC: cjc %import-path %L %l %f
// EXEC: ./main


from okhttp import okhttp.*
from encoding import url.*
from net import http.*

//测试domain 为 内嵌ipv4的ipv6
main() {
    let c = CookieUtil.parse(URL.parse("http://[::180.101.49.13]/foo/bar/baz"),
        "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 dec 2024 08:44:48 GMT; domain=::180.101.49.13")
    match (c) {
        case Some(v) => return 0
        case None => return 1
    }
}