// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from okhttp import okhttp.*
from std import  collection.*
main (){
    let queue = ConcurrentQueue<String>(1)
    queue.poll()
    queue.recycle()
    let queue2 = ConcurrentQueue<String>(-1)
    queue2.recycle()
    queue2.poll()
    return 0
}
