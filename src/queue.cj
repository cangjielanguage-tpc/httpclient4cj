/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the ConcurrentQueue class.
 */

package okhttp

from std import sync.*
from std import collection.ArrayList


/**
 * The class is ConcurrentQueue<T>
 * @since
 */
class ConcurrentQueue<T> <: Iterable<T> {
    private let maxQueueMemory: Int64

    private var list: ArrayList<T> = ArrayList<T>(32)

    private let m: Monitor

    /**
     * The Function is init constructor
     *
     * @param The param is size of Int64
     *
     * @since
     */
    public init(mutex: Monitor, size: Int64) {
        this.m = mutex
        this.maxQueueMemory = size
    }

    /**
     * The Function is init constructor
     *
     *
     * @since
     */
    public init(mutex: Monitor) {
        this.m = mutex
        this.maxQueueMemory = 1024
    }

   public func iterator(): Iterator<T> {
        return list.iterator()
    }

    /**
     * The Function is add
     *
     * @param The param is item of T
     *
     * @since
     */
    public func add(item: T) {
        m.lock()
        try {
            this.list.append(item)
        } finally {
            m.unlock()
        }
    }

   public func get(index: Int64): T {
        synchronized (m) {
            return list[index]
        }
   }

   public func remove(index: Int64 ) {
        synchronized (m) {
            list.remove(index)
        }
   }

   public func removeIf(predicate: (T) -> Bool) {
        list.removeIf(predicate)
   }

   public func size(): Int64  {
        synchronized (m) {
            list.size
        }
   }

    /**
     * The Function is pull
     *
     *
     * @return The return type of Option<T>
     * @since
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

    public func peek(): Option<T> {
        m.lock()
        try {
            return this.list.get(0)
        } finally {
            m.unlock()
        }
    }

    /**
     * The Function is recycle
     *
     *
     * @since
     */
    public func recycle() {
        synchronized (m) {
            this.list.clear()
        }
    }

    public func toArrayList(): ArrayList<T> {
        synchronized (m) {
            return list
        }
    }
}
