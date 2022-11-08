/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the StreamState class.
 */

package h2

/**
 * The enum Conn state.
 */
public enum StreamState <: State{
    | IDLE
    | OPEN
    | RESERVED_LOCAL
    | RESERVED_REMOTE
    | HALF_CLOSED_REMOTE
    | HALF_CLOSED_LOCAL
    | CLOSED

    /**
     * The Function is value
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    public func value(): Int64 {
        return match (this){
            case IDLE               => 0x0
            case OPEN               => 0x1
            case RESERVED_LOCAL     => 0x2
            case RESERVED_REMOTE    => 0x3
            case HALF_CLOSED_REMOTE => 0x4
            case HALF_CLOSED_LOCAL  => 0x5
            case CLOSED             => 0x6
        }
    }
}

extend StreamState <: Equatable<StreamState> {
    public operator func == (that: StreamState): Bool {
        match ((this, that)) {
            case (IDLE, IDLE) => true
            case (OPEN, OPEN) => true
            case (RESERVED_LOCAL, RESERVED_LOCAL) => true
            case (RESERVED_REMOTE, RESERVED_REMOTE) => true
            case (HALF_CLOSED_REMOTE, HALF_CLOSED_REMOTE) => true
            case (HALF_CLOSED_LOCAL, HALF_CLOSED_LOCAL) => true
            case (CLOSED, CLOSED) => true
            case _ => false
        }
    }

    public operator func != (that: StreamState): Bool {
        return !(this == that)
    }
}

/**
 * The enum Stream conf.
 */
public enum StreamConf <: State {
    | SEND_DATA
    | RECV_DATA
    | SEND_HEADERS
    | RECV_HEADERS
    | SEND_PRIORITY
    | RECV_PRIORITY
    | SEND_RST_STREAM
    | RECV_RST_STREAM
    | SEND_SETTINGS
    | RECV_SETTINGS
    | RECV_PUSH_PROMISE
    | SEND_PUSH_PROMISE
    | SEND_PING
    | RECV_PING
    | SEND_GOAWAY
    | RECV_GOAWAY
    | SEND_WINDOWS_UPDATE
    | RECV_WINDOWS_UPDATE
    | RECV_ALTERNATIVE_SERVICE
    | SEND_ALTERNATIVE_SERVICE
    | UPGRADE_SERVER
    | UPGRADE_CLIENT
    | SEND_INFORMATIONAL_HEADERS
    | RECV_INFORMATIONAL_HEADERS
    | SEND_END_STREAM
    | RECV_END_STREAM

    public func value(): Int64 {
        match(this){
            case SEND_DATA                  => 0
            case RECV_DATA                  => 1
            case SEND_HEADERS               => 2
            case RECV_HEADERS               => 3
            case SEND_PRIORITY              => 4
            case RECV_PRIORITY              => 5
            case SEND_RST_STREAM            => 6
            case RECV_RST_STREAM            => 7
            case SEND_SETTINGS              => 8
            case RECV_SETTINGS              => 9
            case RECV_PUSH_PROMISE          => 10
            case SEND_PUSH_PROMISE          => 11
            case SEND_PING                  => 12
            case RECV_PING                  => 13
            case SEND_GOAWAY                => 14
            case RECV_GOAWAY                => 15
            case SEND_WINDOWS_UPDATE        => 16
            case RECV_WINDOWS_UPDATE        => 17
            case RECV_ALTERNATIVE_SERVICE   => 18
            case SEND_ALTERNATIVE_SERVICE   => 19
            case UPGRADE_SERVER             => 20
            case UPGRADE_CLIENT             => 21
            case SEND_INFORMATIONAL_HEADERS => 22
            case RECV_INFORMATIONAL_HEADERS => 23
            case SEND_END_STREAM            => 24
            case RECV_END_STREAM            => 25
        }
    }
}

/**
 * The type Stream state table.
 * @author liyanqing14
 * @since 0.29.3
 */
public class StreamStateTable {
    private static let events: Array<Array<Option<StreamState>>> = [
        /* IDLE */
        [
            /* 0 */  None,
            /* 1 */  None,
            /* 2 */  OPEN,
            /* 3 */  OPEN,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  None,
            /* 7 */  None,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ RESERVED_REMOTE,
            /* 11 */ RESERVED_LOCAL,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ None,
            /* 17 */ None,
            /* 18 */ IDLE,
            /* 19 */ None,
            /* 20 */ HALF_CLOSED_REMOTE,
            /* 21 */ HALF_CLOSED_LOCAL,
            /* 22 */ None,
            /* 23 */ None,
            /* 24 */ None,
            /* 25 */ None
        ],
        /* OPEN */
        [
            /* 0 */  OPEN,
            /* 1 */  OPEN,
            /* 2 */  OPEN,
            /* 3 */  OPEN,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ OPEN,
            /* 11 */ OPEN,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ OPEN,
            /* 17 */ OPEN,
            /* 18 */ OPEN,
            /* 19 */ OPEN,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ OPEN,
            /* 23 */ OPEN,
            /* 24 */ HALF_CLOSED_LOCAL,
            /* 25 */ HALF_CLOSED_REMOTE
        ],
        /*RESERVED_LOCAL*/
        [
            /* 0 */  None,
            /* 1 */  CLOSED,
            /* 2 */  HALF_CLOSED_REMOTE,
            /* 3 */  None,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ None,
            /* 11 */ None,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ RESERVED_LOCAL,
            /* 17 */ RESERVED_LOCAL,
            /* 18 */ RESERVED_LOCAL,
            /* 19 */ RESERVED_LOCAL,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ None,
            /* 23 */ None,
            /* 24 */ None,
            /* 25 */ None
        ],
        /*RESERVED_REMOTE*/
        [
            /* 0 */  None,
            /* 1 */  CLOSED,
            /* 2 */  None,
            /* 3 */  HALF_CLOSED_LOCAL,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ None,
            /* 11 */ None,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ RESERVED_REMOTE,
            /* 17 */ RESERVED_REMOTE,
            /* 18 */ RESERVED_REMOTE,
            /* 19 */ None,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ None,
            /* 23 */ None,
            /* 24 */ None,
            /* 25 */ None
        ],
        /*HALF_CLOSED_REMOTE*/
        [
            /* 0 */  HALF_CLOSED_REMOTE,
            /* 1 */  CLOSED,
            /* 2 */  HALF_CLOSED_REMOTE,
            /* 3 */  CLOSED,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ CLOSED,
            /* 11 */ HALF_CLOSED_REMOTE,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ HALF_CLOSED_REMOTE,
            /* 17 */ HALF_CLOSED_REMOTE,
            /* 18 */ HALF_CLOSED_REMOTE,
            /* 19 */ HALF_CLOSED_REMOTE,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ HALF_CLOSED_REMOTE,
            /* 23 */ None,
            /* 24 */ CLOSED,
            /* 25 */ None
        ],
        /*HALF_CLOSED_LOCAL*/
        [
            /* 0 */  None,
            /* 1 */  HALF_CLOSED_LOCAL,
            /* 2 */  None,
            /* 3 */  HALF_CLOSED_LOCAL,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ HALF_CLOSED_LOCAL,
            /* 11 */ None,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ HALF_CLOSED_LOCAL,
            /* 17 */ HALF_CLOSED_LOCAL,
            /* 18 */ HALF_CLOSED_LOCAL,
            /* 19 */ HALF_CLOSED_LOCAL,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ None,
            /* 23 */ HALF_CLOSED_LOCAL,
            /* 24 */ None,
            /* 25 */ CLOSED
        ],
        /*CLOSED*/
        [
            /* 0 */  CLOSED,
            /* 1 */  CLOSED,
            /* 2 */  CLOSED,
            /* 3 */  CLOSED,
            /* 4 */  None,
            /* 5 */  None,
            /* 6 */  CLOSED,
            /* 7 */  CLOSED,
            /* 8 */  None,
            /* 9 */  None,
            /* 10 */ CLOSED,
            /* 11 */ CLOSED,
            /* 12 */ None,
            /* 13 */ None,
            /* 14 */ None,
            /* 15 */ None,
            /* 16 */ CLOSED,
            /* 17 */ CLOSED,
            /* 18 */ CLOSED,
            /* 19 */ None,
            /* 20 */ None,
            /* 21 */ None,
            /* 22 */ None,
            /* 23 */ None,
            /* 24 */ CLOSED,
            /* 25 */ CLOSED
        ]
    ]

    /**
     * The Function is nextState
     *
     * @param ss of StreamState
     * @param sc of StreamConf
     *
     * @return Type of StreamState
     * @since 0.29.3
     */
    public static func nextState(ss: StreamState, sc: StreamConf): StreamState {
        return match (events[ss.value()][sc.value()]) {
            case Some(v) => return v
            case None    => throw StreamStateException()
        }
    }
}


