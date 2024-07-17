// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import httpclient4cj
import httpclient4cj.*
import std.collection.*

main() {
    let mediaType = MediaType.parse("textx-markdown; charset=utf-8")
    match (mediaType) {
        case Some(contentType) =>
            return 1
        case None => return 0
    }
}

