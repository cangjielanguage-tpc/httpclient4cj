// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import httpclient4cj
import httpclient4cj.*
import encoding.url.*
import net.http.*
import std.unittest.*
import std.unittest.testmacro.*

//测试domain 为 ipv6
main() {
    try {
        let c = CookieUtil.parse(URL.parse("http://[Ff00::b465:310d]/foo/bar/baz"),
            "_zap=613ed211-a464-4e70-ab4e-f9cd9fb1c273; path=foo/bar; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=Ff00::b465:310d"
        )
        println(c.getOrThrow().toSetCookieString())
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
