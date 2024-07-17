// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
import std.unittest.*
import std.unittest.testmacro.*
import net.tls.*
import httpclient4cj
import httpclient4cj.*

main(): Int64 {
    TlsTest().tlsconfig()
    0
}

@Test
public class TlsTest {
    @TestCase
    public func tlsconfig(): Unit {
        var cfg = TlsClientConfig()
        cfg.verifyMode = CertificateVerifyMode.TrustAll
        let client: HttpClient = HttpClient.builder().tlsConfig(cfg).build()
        let mycfg = client.getTlsConfig().getOrThrow()
        // @Assert(mycfg.caFile, "")
        match (mycfg.verifyMode) {
            case CertificateVerifyMode.TrustAll => ()
            case _ => throw Exception()
        }
    }
}
