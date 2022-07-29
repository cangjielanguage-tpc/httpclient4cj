// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import io.*
from okhttp import okhttp.*
from std import time.*
from net import http.*
from std import socket.*

var port: UInt16 = 12340
main() {
    let queue = ConcurrentQueue<String>(10)
    queue.add("queue1")
    queue.add("queue2")
    queue.add("queue3")
    queue.add("queue4")
   
    if(queue.poll().getOrThrow() != "queue1" || queue.peek().getOrThrow() != "queue2") {
        return -1
    }
    queue.recycle()
    return 0
}

