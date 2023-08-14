// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from net import tls.*

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
