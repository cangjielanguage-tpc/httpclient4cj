// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import collection.*

main() {
    let mediaType = MediaType.parse("textx-markdown; charset=utf-8")
    match (mediaType) {
        case Some(contentType) =>
            return 1
        case None => return 0
    }
}

