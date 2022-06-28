/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the FileUtils class.
 */
package okhttp


/**
 * The interface is Callback
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public interface Callback {
    /*
     * The Function is onFailure
     *
     * @param call of Call
     * @param e of Exception
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func onFailure(call: Call,  e: Exception): Unit

    /*
     * The Function is onResponse
     *
     * @param call of Call
     * @param response of Response
     *
     * @return Type of Unit
     * @since 0.29.3
     */
    func onResponse(call: Call,  response: Response): Unit
}