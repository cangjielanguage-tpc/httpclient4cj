// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from encoding import url.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let url1 = URL.parse("vscode-remote://wsl%2Bubuntu/home/young/cangjie_projects/httpclient4cj/test/LLT/test_CacheControl.cj")
    println(url1.toString())
    let url2 = URL.parse("https://cn.bing.com/search?q=spring+boot+ContainerCustomizer&qs=n&form=QBRE&sp=-1&lq=0&pq=spring+boot+containercustomizer&sc=10-31&sk=&cvid=4B3B9B58D4E84077A87B4A13A5E8E32F&ghsh=0&ghacc=0&ghpl=")
    println(url2.toString())

    let res1 = Cache.key(url1)
    println(res1)
    let res2 = Cache.key(url2)
    println(res2)

    @Assert(res1, "366bdcfa8769850b19e81ae7431e15da")
    @Assert(res2, "7d6ad66d8b5796794e9fbe57835d241e")
    return 0
}
