/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the ConcurrentQueue<T> class.
 */

package okhttp

from std import sync.*
from std import collection.ArrayList


/**
 * The class is ConcurrentQueue<T> inherited from Iterable<T>
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class ConcurrentQueue<T> <:  Iterable<T>{
    /* let member maxQueueMemory type is Int64 */
    private let maxQueueMemory: Int64

    /* var member list type is ArrayList<T> */
    private var list: ArrayList<T> = ArrayList<T>(32)

    /* let member m type is ReentrantMutex */
    private let m: ReentrantMutex = ReentrantMutex()

    /**
     * The Function is init constructor
     *
     * @param size of Int64
     * @since 0.29.3
     */
    public init(size: Int64) {
        this.maxQueueMemory = size
    }

    /**
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    public init() {
        this.maxQueueMemory = 1024
    }

   /**
    * The Function is iterator
    *
    * @return Type of Iterator<T>
    * @since 0.29.3
    */
   public func iterator(): Iterator<T> {
        return list.iterator()
    }

    /**
     * The Function is add
     *
     * @param item of T
     * @since 0.29.3
     */
    public func add(item: T) {
        m.lock()
        try {
            this.list.add(item)
        } finally {
            m.unlock()
        }
    }

    /**
     * The Function is poll
     *
     * @return Type of Option<T>
     * @since 0.29.3
     */
    public func poll(): Option<T> {
        m.lock()
        try {
            let ret = this.list.get(0)
            return match (ret) {
                case Some(v) =>
                    this.list.remove(0)
                    return ret
                case None => ret
            }
        } finally {
            m.unlock()
        }
    }


    /**
     * The Function is recycle
     *
     * @since 0.29.3
     */
    public func recycle() {
        synchronized(m) {
            this.list.clear()
        }
    }

    /**
     * The Function is toArrayList
     *
     * @return Type of ArrayList<T>
     * @since 0.29.3
     */
    public func toArrayList(): ArrayList<T> {
        return list
    }
}
