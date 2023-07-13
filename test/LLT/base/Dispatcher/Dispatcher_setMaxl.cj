// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from httpclient4cj import httpclient4cj.*
from std import io.*

main () {
    let d = Dispatcher()
    d.setIdleCallback(Option<()-> Unit>.None)
    try{
        d.setMaxRequests(0)
    }catch(e: Exception) {
        return 0
    }

    return 1
}
