/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the ConnectionState class.
 */

package h2

from http2 import exceptions.*

/**
 * The interface is State
 * @author liyanqing14
 * @since 0.29.3
 */
public interface State {
    /*
     * The Function is value
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    func value(): Int64
}

/**
 * The enum Conn state.
 */
public enum ConnectionState <: State{
    | IDLE
    | SERVER_OPEN
    | CLIENT_OPEN
    | CLOSE

    /**
     * The Function is value
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    public func value(): Int64 {
        return match (this){
            case IDLE        => 0x0
            case SERVER_OPEN => 0x1
            case CLIENT_OPEN => 0x2
            case CLOSE       => 0x3
        }
    }
}
/**
 * The Function is conn_SEND_HEADERS
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_SEND_HEADERS(id: ConnectionState): ConnectionState {
    match (id){
        case IDLE => return ConnectionState.CLIENT_OPEN
        case SERVER_OPEN => return ConnectionState.SERVER_OPEN
        case _ => throw StateException()
    }
}
/**
 * The Function is conn_RECV_HEADERS
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_RECV_HEADERS(id: ConnectionState): ConnectionState {
    match (id){
        case IDLE => return ConnectionState.SERVER_OPEN
        case SERVER_OPEN => return ConnectionState.SERVER_OPEN
        case CLIENT_OPEN => return ConnectionState.CLIENT_OPEN
        case _ => throw StateException()
    }
}
/**
 * The Function is conn_RECV_ALTERNATIVE_SERVICE
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_RECV_ALTERNATIVE_SERVICE(id: ConnectionState): ConnectionState {
    match (id){
        case IDLE => return ConnectionState.CLIENT_OPEN
        case SERVER_OPEN => return ConnectionState.SERVER_OPEN
        case CLIENT_OPEN => return ConnectionState.CLIENT_OPEN
        case _ => throw StateException()
    }
}
/**
 * The Function is conn_SEND_ALTERNATIVE_SERVICE
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_SEND_ALTERNATIVE_SERVICE(id: ConnectionState): ConnectionState {
    match (id){
        case IDLE => return ConnectionState.SERVER_OPEN
        case SERVER_OPEN => return ConnectionState.SERVER_OPEN
        case CLIENT_OPEN => return ConnectionState.CLIENT_OPEN
        case _ => throw StateException()
    }
}
/**
 * The Function is conn_SEND_GOAWAY
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_SEND_GOAWAY(id: ConnectionState): ConnectionState {
    return ConnectionState.CLOSE
}
/**
 * The Function is conn_RECV_GOAWAY
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_RECV_GOAWAY(id: ConnectionState): ConnectionState {
    return ConnectionState.CLOSE
}
/**
 * The Function is conn_other_state
 *
 * @param id of ConnectionState
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_other_state(id: ConnectionState): ConnectionState {
    match (id){
        case IDLE => return ConnectionState.SERVER_OPEN
        case SERVER_OPEN => return ConnectionState.SERVER_OPEN
        case CLIENT_OPEN => return ConnectionState.CLIENT_OPEN
        case CLOSE => throw StateException()
    }
}
/**
 * The Function is conn_other_error
 *
 * @return Type of ConnectionState
 * @since 0.29.3
 */
public func conn_other_error(): ConnectionState {
    throw CnnectionStateException()
}

public enum ConnConf <: State {
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

    public func value(): Int64 {
        match(this){
            case SEND_DATA                 => 0
            case RECV_DATA                 => 1
            case SEND_HEADERS              => 2
            case RECV_HEADERS              => 3
            case SEND_PRIORITY             => 4
            case RECV_PRIORITY             => 5
            case SEND_RST_STREAM           => 6
            case RECV_RST_STREAM           => 7
            case SEND_SETTINGS             => 8
            case RECV_SETTINGS             => 9
            case RECV_PUSH_PROMISE         => 10
            case SEND_PUSH_PROMISE         => 11
            case SEND_PING                 => 12
            case RECV_PING                 => 13
            case SEND_GOAWAY               => 14
            case RECV_GOAWAY               => 15
            case SEND_WINDOWS_UPDATE       => 16
            case RECV_WINDOWS_UPDATE       => 17
            case RECV_ALTERNATIVE_SERVICE  => 18
            case SEND_ALTERNATIVE_SERVICE  => 19
        }
    }
}

/**
 * The type Conn state table.
 * @author liyanqing14
 * @since 0.29.3
 */
public class ConnStateTable {
    private static let connEvents: Array<Array<()->ConnectionState>> = [
        /* IDLE */
        [
            /* 0 */  conn_other_error,
            /* 1 */  conn_other_error,
            /* 2 */  {=> conn_SEND_HEADERS(ConnectionState.IDLE)},
            /* 3 */  {=> conn_RECV_HEADERS(ConnectionState.IDLE)},
            /* 4 */  {=> conn_other_state(ConnectionState.IDLE)},
            /* 5 */  {=> conn_other_state(ConnectionState.IDLE)},
            /* 6 */  conn_other_error,
            /* 7 */  conn_other_error,
            /* 8 */  {=> conn_other_state(ConnectionState.IDLE)},
            /* 9 */  {=> conn_other_state(ConnectionState.IDLE)},
            /* 10 */ conn_other_error,
            /* 11 */ conn_other_error,
            /* 12 */ {=> conn_other_state(ConnectionState.IDLE)},
            /* 13 */ {=> conn_other_state(ConnectionState.IDLE)},
            /* 14 */ {=> conn_SEND_GOAWAY(ConnectionState.IDLE)},
            /* 15 */ {=> conn_RECV_GOAWAY(ConnectionState.IDLE)},
            /* 16 */ {=> conn_other_state(ConnectionState.IDLE)},
            /* 17 */ {=> conn_other_state(ConnectionState.IDLE)},
            /* 18 */ {=> conn_RECV_ALTERNATIVE_SERVICE(ConnectionState.IDLE)},
            /* 19 */ {=> conn_SEND_ALTERNATIVE_SERVICE(ConnectionState.IDLE)}
        ],
        /* SERVER_OPEN */
        [
            /* 0 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 1 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 2 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 3 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 4 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 5 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 6 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 7 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 8 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 9 */   {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 10 */  conn_other_error,
            /* 11 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 12 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 13 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 14 */  {=> conn_SEND_GOAWAY(ConnectionState.SERVER_OPEN)},
            /* 15 */  {=> conn_RECV_GOAWAY(ConnectionState.SERVER_OPEN)},
            /* 16 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 17 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 18 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)},
            /* 19 */  {=> conn_other_state(ConnectionState.SERVER_OPEN)}
        ],
        /* CLIENT_OPEN */
        [
            /* 0 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 1 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 2 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 3 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 4 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 5 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 6 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 7 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 8 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 9 */   {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 10 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 11 */  conn_other_error,
            /* 12 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 13 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 14 */  {=> conn_SEND_GOAWAY(ConnectionState.CLIENT_OPEN)},
            /* 15 */  {=> conn_RECV_GOAWAY(ConnectionState.CLIENT_OPEN)},
            /* 16 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 17 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 18 */  {=> conn_other_state(ConnectionState.CLIENT_OPEN)},
            /* 19 */  conn_other_error
        ],
        /* CLOSE */
        [
            /* 0 */   conn_other_error,
            /* 1 */   conn_other_error,
            /* 2 */   conn_other_error,
            /* 3 */   conn_other_error,
            /* 4 */   conn_other_error,
            /* 5 */   conn_other_error,
            /* 6 */   conn_other_error,
            /* 7 */   conn_other_error,
            /* 8 */   conn_other_error,
            /* 9 */   conn_other_error,
            /* 10 */  conn_other_error,
            /* 11 */  conn_other_error,
            /* 12 */  conn_other_error,
            /* 13 */  conn_other_error,
            /* 14 */  {=> conn_SEND_GOAWAY(ConnectionState.CLOSE)},
            /* 15 */  {=> conn_RECV_GOAWAY(ConnectionState.CLOSE)},
            /* 16 */  conn_other_error,
            /* 17 */  conn_other_error,
            /* 18 */  conn_other_error,
            /* 19 */  conn_other_error
        ]
    ]

    /**
     * The Function is nextConnState
     *
     * @param cs of ConnectionState
     * @param cc of ConnConf
     *
     * @return Type of ConnectionState
     * @since 0.29.3
     */
    public static func nextConnState(cs: ConnectionState, cc: ConnConf): ConnectionState {
        return connEvents[cs.value()][cc.value()]()
    }
}


