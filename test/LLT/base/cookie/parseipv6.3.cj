// EXEC: cjc %import-path %L %l %f
// EXEC: ./main


from httpclient4cj import httpclient4cj.*
from encoding import url.*
from net import http.*

//测试domain 和 URl 不匹配 期望为1
main() {
    let c = CookieUtil.parse(URL.parse("http://[FF00::b465:310d]/foo/bar/baz"),
        "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=fFee::b465:310d")
    match (c) {
        case Some(v) => return 1
        case None => return 0
    }
}