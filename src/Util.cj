/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the Util class.
 */
package okhttp

/**
 * The class is Util
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class Util {

    /**
     * The Function is closeQuietly
     *
     * @param Stream of BufferStream
     * @since 0.29.3
     */
    public static func closeQuietly(Stream: BufferStream) {
        try {
            Stream.close()
        } catch (rethrown: RuntimeException) {
            println(rethrown.toString())
        } catch (ignored: Exception) {
            println(ignored.toString())
        }
    }

}