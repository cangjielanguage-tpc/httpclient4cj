/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the Http2ConnPool class.
 */
package h2

from std import log.*

let initialHeaderTableSize: Int64 = 4096

let defaultMaxConcurrentStreams = 250

let globalinitialWindowSize: Int64 = 65535 // 6.9.2 Initial Flow Control Window Size

let initialMaxFrameSize: Int64 = 16384

let initialMaxHeadListSize = 1048896

/**
 * The class is H2Config
 * @author liyanqing14
 * @since 0.29.3
 */
public open class H2Config {
    public var HEADER_TABLE_SIZE: Int64
    public var ENABLE_PUSH: Int64
    public var MAX_CONCURRENT_STREAMS: Int64
    public var INITIAL_WINDOW_SIZE: Int64
    public var MAX_FRAME_SIZE: Int64
    public var MAX_HEADER_LIST_SIZE: Int64

    /**
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    public init (){
        /* 
         * The sender is allowed to notify the remote endpoint of the maximum size of the header compression table used to decode the header block in octets. 
         * The encoder can select any size equal to or less than this value by using a signal specific to the header compression format within the header block (see COMPRESSION). 
         * The initial value is 4096 octets.
         */
        this.HEADER_TABLE_SIZE = initialHeaderTableSize

        /* 
         * This setting can be used to disable server push (Section 8.2). 
         * If the endpoint receives this parameter and it is set to 0, 
         * the endpoint must not send PUSH_ PROMISE frame. 
         * The endpoint that has set this parameter to 0 and confirmed it must be PUSH_ Receive PROMISE frame as PROTOCOL_ ERROR type connection error (Section 5.4.1). 
         * The initial value is 1, 
         * which means the server is allowed to push. Any value other than 0 or 1 must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).
         */
        this.ENABLE_PUSH = 1

        /* 
         * Indicates the maximum number of concurrent streams allowed by the sender. 
         * This limit is directional: it applies to the number of flows that the sender allows the receiver to create. 
         * When initializing, there is no limit to this value. 
         * It is recommended that this value should not be less than 100 to avoid unnecessarily limiting parallelism. 
         * When SETTINGS_ MAX_ CONCURRENT_ The value 0 of STREAMS should not be treated as a special value by the endpoint. 
         * A value of zero does prevent the creation of new streams; 
         * However, it also applies to any limit on the exhaustion of activated streams. 
         * The server should only set a zero value for short connections; 
         * If the server does not want to accept requests, it is more appropriate to close the connection.
         */
        this.MAX_CONCURRENT_STREAMS = defaultMaxConcurrentStreams
        
        /* 
         * Indicates the sender's initial window size (in octets), which is used for stream level flow control. 
         * The initial value is 2 ^ 16-1 (65535) octets. This setting affects the window size of all streams (see section 6.9.2). 
         * Values higher than the maximum flow control window size of 2 ^ 31-1 must be considered FLOW_ CONTROL_ ERROR type connection error (Section 5.4.1).
         */
        this.INITIAL_WINDOW_SIZE = globalinitialWindowSize
        
        /* 
         * Indicates the size of the maximum frame payload that the sender is willing to receive (in octets). 
         * The initial value is 2 ^ 14 (16384) octets. 
         * The value of the endpoint broadcast must be between this initial value and the maximum allowed frame size (2 ^ 24-1 or 16777215 octets), including both.
         * Values outside this range must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).
         */
        this.MAX_FRAME_SIZE = initialMaxFrameSize
        
        /* 
         * This notification setting notifies the peer in the form of eight bytes, 
         * and the sender is prepared to accept the maximum size of the header list. 
         * The value is based on the uncompressed size of the header field, 
         * including the name and value length of octets plus the cost of 32 octets for each header field. 
         * For any given request, the lower limit below the recommended value can be enforced. 
         * The initial value of this setting is unlimited.
         */
        this.MAX_HEADER_LIST_SIZE = initialMaxHeadListSize
    }
}
