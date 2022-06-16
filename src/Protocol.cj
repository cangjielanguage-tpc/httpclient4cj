
package okhttp


public enum Protocol {
    /**
    * An obsolete plaintext framing that does not use persistent sockets by default.
    */
   | HTTP_1_0(String) | HTTP_1_1(String) | SPDY_3(String) |  HTTP_2(String) | H2_PRIOR_KNOWLEDGE(String) | QUIC(String)

    public static func get(protocol: String): Protocol {

        return match (protocol) {
            case "http/1.0" => HTTP_1_0("http/1.0")
            case "http/1.1" => HTTP_1_1("http/1.1")
            case "spdy/3.1" => SPDY_3("spdy/3.1")
            case "h2" => HTTP_2("h2")
            case "h2_prior_knowledge" => H2_PRIOR_KNOWLEDGE("h2_prior_knowledge")
            case "quic" => H2_PRIOR_KNOWLEDGE("quic")
            case _  => throw Exception()

        }
    }

    public func toString(): String {
        match (this) {
            case HTTP_1_0("http/1.0") => "http/1.0"
            case HTTP_1_1("http/1.1") => "http/1.1"
            case SPDY_3("spdy/3.1") => "spdy/3.1"
            case HTTP_2("h2") => "h2"
            case H2_PRIOR_KNOWLEDGE("h2_prior_knowledge") => "h2_prior_knowledge"
            case H2_PRIOR_KNOWLEDGE("quic") => "quic"
            case _ => throw Exception()
        }
    }
}
