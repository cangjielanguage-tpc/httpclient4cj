// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import collection.*

main() {
    let mediaType = MediaType.parse("text/x-markdown; charset='utf-8'")
    match (mediaType) {
        case Some(contentType) =>
            let tp = contentType.getType()
            let sub = contentType.getSubtype()
            let charset = contentType.getCharset()
            if (tp == "text" && sub == "x-markdown" && charset == "utf-8") {
                return 0
            }
            return 1
        case None => return 1
    }
}

