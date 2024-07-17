// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import encoding.url.*
import net.http.*
import std.unittest.*
import std.unittest.testmacro.*

//测试domain 为 内嵌ipv4的ipv6
main() {
    try {
        let c = CookieUtil.parse(URL.parse("http://[::180.101.49.13]/foo/bar/baz"),
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 dec 2024 08:44:48 GMT; domain=::180.101.49.13"
        )
        match (c) {
            case Some(_) => return 0
            case None => return 1
        }
    } catch (e: Exception) {
        @Assert(e.message, "invalid cookie domain")
        return 0
    }
    return 1
}
