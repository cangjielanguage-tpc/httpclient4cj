// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import net.tls.*

main() {
    try {
        var cfg = TlsClientConfig()
        cfg.verifyMode = TrustAll
        let _: HttpClient = HttpClient.builder().tlsConfig(cfg).build()
    } catch (e: Exception) {
        return 1
    }
    return 0
}
