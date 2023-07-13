// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from std import unittest.*
from std import unittest.testmacro.*
from net import tls.*
from httpclient4cj import httpclient4cj.*

main(): Int64 {
    TlsTest().tlsconfig()
    0
}

@Test
public class TlsTest {
    @TestCase
    public func tlsconfig(): Unit {
        var cfg = TlsClientConfig("../data/test.cer")
        cfg.verifyMode = TlsClientVerifyMode.VerifyNone
        let client: HttpClient = HttpClient.builder().tlsConfig(cfg).build()
        let mycfg = client.getTlsConfig().getOrThrow()
        @Assert(mycfg.caFile, "../data/test.cer")
        match (mycfg.verifyMode) {
            case TlsClientVerifyMode.VerifyNone => ()
            case _ => throw Exception()
        }
    }
}
