// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*
from encoding import url.*
main() {
   try {
       let cookieUtil5 = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"),
           "<sdf>[sdf](sdf){sdf}=abc; expires=Sun, 13 Oct 2024 08:44:48 GMT; domain=.example.com")
       println("cookieUtil5")
       println(cookieUtil5.getOrThrow().toString())
   } catch (e: Exception) {
       return 0
   }
   return 1
}

