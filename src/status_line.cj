/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declars the StatusLine class.
 */
package okhttp

/**
 * The class is StatusLine
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class StatusLine {
    /** var member HTTP_TEMP_REDIRECT type is Int64 */
    public static var HTTP_TEMP_REDIRECT: Int64 = 307
    /** var member HTTP_PERM_REDIRECT type is Int64 */
    public static var HTTP_PERM_REDIRECT: Int64 = 308
    /** var member HTTP_MULT_CHOICE type is Int64 */
    public static var HTTP_MULT_CHOICE: Int64 = 300
    /** var member HTTP_MOVED_PERM type is Int64 */
    public static var HTTP_MOVED_PERM: Int64 = 301
    /** var member HTTP_MOVED_TEMP type is Int64 */
    public static var HTTP_MOVED_TEMP: Int64 = 302
    /** var member HTTP_SEE_OTHER type is Int64 */
    public static var HTTP_SEE_OTHER: Int64 = 303
}