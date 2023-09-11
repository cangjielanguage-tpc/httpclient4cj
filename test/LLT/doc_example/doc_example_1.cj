// DEPENDENCE: testserver.cj
// EXEC: cjc %import-path %L %l %f testserver.cj
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import time.*

main() {
    let client: HttpClient = HttpClient.builder()
        .connectTimeout(Duration.second)
        .readTimeout(Duration.second)
        .writeTimeout(Duration.second)
        .build()
}