// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import io.*

main () {
    let d = Dispatcher()
    d.setIdleCallback(Option<()-> Unit>.None)
    try{
        d.setMaxRequestsPerHost(0)
    }catch (e: Exception) {
        return 0
    }

    return 1
}
