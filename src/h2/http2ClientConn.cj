/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the xxxx class.
 */

package h2

from net import http.*
from std import time.*
from std import math.*
from std import socket.*
from std import collection.*
from net import tls.*
from std import os.posix.*
from http2 import buffer.*
from http2 import frame.*
from http2 import hpack.*
from http2 import http.*
from http2 import exceptions.*

/*
 * The preamble of the client sending connection is divided into three cases
 *   - After receiving the 101 response, the client sends the connection preamble
 *   - As the first batch of application data for TLS connection
 *   - If you know in advance that the server supports http/2, send it when the connection is established
 *   
 *   idle: Stream is not currently enabled
 *   open: Stream is currently in use
 *   closed: Stream has been used
 *   reserved(local): Local reservation, about to be used but not yet used
 *   reserved(remote): Remote reservation, about to be used but not used
 *   half closed(local): Local semi closed, about to close but not yet closed
 *   half closed(remote): Remote half closed, about to close but not yet closed
 *
 */
let transportDefaultConnFlow = 1 << 30

let transportDefaultStreamFlow = 4 << 20

let transportDefaultStreamMinRefresh = 4 << 10

let defaultUserAgent = "cangjie-http-client/2.0"

let initialMaxConcurrentStreams: UInt32 = 100

let PREFACE: String = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"

let NextProtoTLS = "h2"

let defaultMaxReadFrameSize: Int64 = 1 << 20

let connReadLength: Int64 = 20480

var connReadArray: Array<UInt8> = Array<UInt8>(connReadLength, item: 0)

/**
 * The class is H2ClientConn /* inherited from Hashable & Equatable<H2ClientConn> */
 * @author liyanqing14
 * @since 0.29.3
 */
public open class H2ClientConn /* <: Hashable & Equatable<H2ClientConn> */ {
    protected var hts: H2Transport
    protected var socket: SocketClient
    protected var nextStreamID: AtomicUInt32
    protected var closed: AtomicBool
    protected var closing: AtomicBool
    protected var maxFrameSize: UInt32
    protected var maxConcurrentStreams: UInt32
    protected var peerMaxHeaderListSize: UInt64
    protected var streams: SyncMap<UInt32, H2ClientStream>

    protected var initialWindowSize: UInt32
    static var muLock: ReentrantMutex = ReentrantMutex()
    var wmuLock: ReentrantMutex = ReentrantMutex()
    protected var status: ConnectionState = IDLE

    protected let hpackDecode: Decoder = Decoder.newDecode()
    protected let hpackEncode: Encoder = Encoder.newEncoder()

    private var readFrame: SyncQueue<Http2Frame>
    protected var inflow: Flow = Flow()
    public var loop: H2ClientConnReadLoop
    public var writeloop: H2ClientConnWriteLoop
    protected var frd: FramesDecoder = FramesDecoder()
    protected var myConf = H2Config()
    protected var mywriteStream: ConcurrentQueue<Http2Frame> = ConcurrentQueue<Http2Frame>()

    /* whether being used for a single http.Request. */
    protected var isSingleUse: AtomicBool = AtomicBool(false)
    public prop var singleUse: Bool {
        get() { return this.isSingleUse.load() }
        set(value) { this.isSingleUse.store(value) }
    }
    /* used by clientConnPool */
    protected var isCanTakeNewRequest: AtomicBool = AtomicBool(false)
    public prop var canTakeNewRequest: Bool {
        get() { return this.isCanTakeNewRequest.load() }
        set(value) { this.isCanTakeNewRequest.store(value) }
    }
    /* time last idle */
    protected var lastIdle: Time = Time.now()
    protected var streamsReserved: AtomicInt64 = AtomicInt64(0)
    /* requests blocked and waiting to be sent because len(streams) == maxConcurrentStreams */
    protected var pendingRequests: AtomicInt64 = AtomicInt64(0)

    public prop let conn:   SocketClient          { get() { return socket }}
    prop let wmu:    ReentrantMutex  { get() { return wmuLock }}
    prop let mu:     ReentrantMutex  { get() { return muLock }}
    public prop let conf:   H2Config        { get() { return myConf }}
    public prop let encode: Encoder         { get() { return hpackEncode }}
    public prop let decode: Decoder         { get() { return hpackDecode }}
    public prop let ws:     ConcurrentQueue<Http2Frame>         { get() { return mywriteStream }}
    public prop let streamMap: SyncMap<UInt32, H2ClientStream>  { get() {return streams }}
    // public prop let pings:  ConcurrentQueue<Array<UInt8>>   { get() { return mypings }}
    public prop var connState: ConnectionState {
        get() {return status}
        set(value) {this.status = value}
    }

    // Define request http2
    private static let defaultRequestBytes = PREFACE.toUtf8Array()
    // private static let defaultSettingBytes = FrameFactory.getFactory().newSETTINGS([FrameSetting(MAX_CONCURRENT_STREAMS, 100), FrameSetting(INITIAL_WINDOW_SIZE, 1073741824), FrameSetting(ENABLE_PUSH, 0)]).getPayload().toArray()

    private init(hts: H2Transport, conn: SocketClient, id: UInt32, maxFrameSize: UInt32, initialWindowSize: UInt32,
                maxConcurrentStreams: UInt32, peerMaxHeaderListSize: UInt64, streams: Map<UInt32, H2ClientStream> ) {
        this.hts = hts
        this.socket = conn
        this.nextStreamID = AtomicUInt32(id)
        this.maxFrameSize = maxFrameSize
        this.initialWindowSize = initialWindowSize
        this.maxConcurrentStreams = maxConcurrentStreams
        this.peerMaxHeaderListSize = peerMaxHeaderListSize
        this.streams = SyncMap<UInt32, H2ClientStream>(streams)
        this.closed = AtomicBool(false)
        this.closing = AtomicBool(false)
        this.loop = H2ClientConnReadLoop(Option<H2ClientConn>.None, Option<SocketClient>.None)
        this.writeloop = H2ClientConnWriteLoop(Option<H2ClientConn>.None, Option<SocketClient>.None)
        this.readFrame = SyncQueue<Http2Frame>(Int64(maxFrameSize))
    }

    /**
     * The Function is createClientConn
     *
     * @param hts of H2Transport
     * @param conn of Socket
     * @param id of UInt32
     * @param mfs of UInt32
     * @param iws of UInt32
     * @param mcs of UInt32
     * @param pmhls of UInt64
     * @param streams of Map<UInt32,H2ClientStream>
     *
     * @return Type of H2ClientConn
     * @since 0.29.3
     */
    public static func createClientConn(hts: H2Transport, conn: SocketClient, id: UInt32, mfs: UInt32, iws: UInt32,
                mcs: UInt32, pmhls: UInt64, streams: Map<UInt32, H2ClientStream>) : H2ClientConn {
        synchronized(muLock) {
            try {
                let hcc: H2ClientConn = H2ClientConn(hts, conn, id, mfs, iws, mcs, pmhls, streams)
                if (!hcc.loop.setClientConn(hcc, conn, mcs)) {
                    throw Exception("clientconn: The loop read tool has been initialized.")
                }
                if (!hcc.writeloop.setClientConn(hcc, conn)) {
                    throw Exception("clientconn: The loop read tool has been initialized.")
                }
                hcc.inflow.add(transportDefaultConnFlow + Int64(globalinitialWindowSize))
                let wrote2 = hcc.conn.write(defaultRequestBytes)
                hcc.ws.put(FrameFactory.getFactory().newSETTINGS([ FrameSetting(MAX_CONCURRENT_STREAMS, 250) ]))
                spawn {
                    hcc.readLoop()
                }
                spawn {
                    hcc.writeLoop()
                }
                return hcc
            } catch (e: Exception) {
                e.printStackTrace()
                throw e
            }
        }
    }

    /**
     * The Function is createClientConn
     *
     * @param hts of H2Transport
     * @param conn of Socket
     *
     * @return Type of H2ClientConn
     * @since 0.29.3
     */
    public static func createClientConn(hts: H2Transport, conn: Socket) : H2ClientConn {
        return H2ClientConn.createClientConn(hts, SocketC(conn), 1, 16 << 10, 65535,
            initialMaxConcurrentStreams, UInt64.Max, HashMap<UInt32, H2ClientStream>())
    }

    public static func createClientConn(hts: H2Transport, conn: TlsSocket) : H2ClientConn {
        return H2ClientConn.createClientConn(hts, TlsC(conn), 1, 16 << 10, 65535,
            initialMaxConcurrentStreams, UInt64.Max, HashMap<UInt32, H2ClientStream>())
    }

    public static func createClientConn(hts: H2Transport, conn: SocketClient) : H2ClientConn {
        return H2ClientConn.createClientConn(hts, conn, 1, 16 << 10, 65535,
            initialMaxConcurrentStreams, UInt64.Max, HashMap<UInt32, H2ClientStream>())
    }
    /**
     * The Function is decodeFrame
     *
     * @param arr of Collection<UInt8>
     *
     * @return Type of Collection<Http2Frame>
     * @since 0.29.3
     */
    public func decodeFrame(arr: Collection<UInt8>): Collection<Http2Frame> {
        this.frd.decode(ByteBuffer(arr))
        return this.frd.arrayFrame
    }

    /**
     * The Function is readLoop
     *
     * @since 0.29.3
     */
    public func readLoop() {
        this.wmu.lock()
        let e = this.loop.run()
        match(e) {
            case Some(v) => this.ws.put(FrameFactory.getFactory().newGOAWAY(0, v, ""))
            case None => ()
        }
        this.wmu.unlock()
        this.loop.cleanUp()
    }

    /**
     * The Function is writeLoop
     *
     * @since 0.29.3
     */
    public func writeLoop() {
        // this.wmu.lock()
        this.writeloop.run()
    }

    /**
     * The Function is doRequest
     *
     * @param req of H2Request
     *
     * @return Type of H2Response
     * @since 0.29.3
     */
    public func doRequest(req: H2Request): H2Response{
        synchronized(muLock) {
            let id = this.nextStreamID
            this.nextStreamID.fetchAdd(2)
            let h2Stream: H2ClientStream = H2ClientStream.newStream(id.load(), this, req.body)
            h2Stream.doRequestHttp2(req)
            this.streams.put(id.load(), h2Stream)
            for (frame in h2Stream.getFrames()) {
                this.ws.put(frame)
            }
            h2Stream.isEndStream.poll()
            return h2Stream.resp
        }
    }

    /*
     * It is similar to cantakenewrequest, but it also retains a concurrent flow in CC.
     * Reservations will be reduced on the next call round trip.
     */
    public func reserveNewRequest(): Bool {
        idleStateLocked()
        if (!this.canTakeNewRequest) {
            return false
        }
        this.streamsReserved.fetchAdd(1)
        return true
    }

    func idleStateLocked(): Unit {
        if (this.singleUse && this.nextStreamID.load() > 1) {
            return ()
        }
        /* We will tell the caller that we can accept a new request to prevent the caller from dialing a new TCP connection,
         * but we will block it later before writing.
         */
        var maxConcurrentOkay: Bool = if (this.hts.strictMaxConcurrentStreams) {
            true
        } else {
            Int64(this.streams.size() + this.streamsReserved.load() + 1) <= Int64(this.maxConcurrentStreams)
        }
        let isTooIdleLocked: Bool = tooIdleLocked()
        this.canTakeNewRequest = !this.closed.load() && !this.closing.load() && maxConcurrentOkay &&
            (Int64(this.nextStreamID.load()) + 2 * Int64(this.pendingRequests.load())) < Int64(Int32.Max) &&
            !isTooIdleLocked
        return ()
    }

    /* Reports whether this connection has been idle for too long. */
    func tooIdleLocked(): Bool {
        return this.hts.idleTimeout.seconds() != 0 && !timeIsZero(this.lastIdle) && Time.since(this.lastIdle) > this.hts.idleTimeout
    }
}

/*
 * The key to realize multiplexing
 * 1. The sender can send multiple stream messages concurrently
 * 2. The implementation of the receiving end can concurrently assemble messages based on this
 * 3. Freems in the same stream must be ordered
 * 4. SETTING_MAX_CONCURRECT_STREAMS: Control the number of concurrent streams
 *
 * Start a new thread to process and accept the byte stream of the opposite end,
 * Flow state constraints
 * 1. The newly created stream ID must be greater than the established stream ID with the status of opened and reserved
 * 2. When sending on a newly established stream, the established stream in idle state must be closed to cloesd
 * 3. The stream ID cannot be reused. When the long connection is exhausted, the connection must be closed and re established

SETTINGS frame Correct handling and exception handling
flags:
  ACK:  SETTINGS: Processing order must be in the order of sending.Once all the values have been processed, the receiver must send a settings containing an ACK. The sender can continue sending after that.
 
Abnormal condition:
 一、SETTINGS: It is for the global connection, so the stream ID must be 0, or a protocol will be thrown_ Error error.
 二、SETTINGS: It will affect the connection status. An incomplete or erroneous settings must be regarded as an error and a protocol will be thrown_ ERROR.
 三、SETTINGS: If the length exceeds 6 bytes, a frame will be thrown_ SIZE_ ERROR
 四、If settings_ ENABLE_ Push is set to 1, but the server sent a push_ Promise, the protocol will be thrown_ ERROR
 五、If settings_ INITIAL_ WINDOW_ Size: if it exceeds 2^31-1, flow will be thrown_ CONTROL_ ERROR
 六、If settings is sent but no ack is received, settings will be thrown_ TIMEOUT
 */


/**
 * The class is H2ClientConnReadLoop
 * @author liyanqing14
 * @since 0.29.3
 */
public open class H2ClientConnReadLoop {
    protected var cc: ?H2ClientConn
    private var isConn: Bool 
    private var socket: ?SocketClient

    private var hpackdecode: Decoder

    private var framedecode: FramesDecoder = FramesDecoder()

    private var frist: Bool = true

    private let frameFactory = FrameFactory.getFactory()

    private static let CRLF = "\r\n"
    private static let CRLF_SIZE = CRLF.size

    /**
     * The Function is init constructor
     *
     * @param cc of ?H2ClientConn
     * @param s of ?Socket
     * @since 0.29.3
     */
    public init (cc: ?H2ClientConn, s: ?SocketClient) {
        this.cc = cc
        this.socket = s
        this.isConn = match ((cc, s)) {
            case (Some(v), Some(w)) => true
            case _ => false
        }
        this.hpackdecode = Decoder.newDecode()
    }

    /**
     * The Function is setClientConn
     *
     * @param cc of H2ClientConn
     * @param s of Socket
     * @param mcs of UInt32
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func setClientConn(cc: H2ClientConn, s: SocketClient, mcs: UInt32): Bool {
        this.hpackdecode = Decoder.newDecode(Int64(mcs))
        if (this.isConn) {
            return !this.isConn
        } else {
            this.cc = Some(cc)
            this.socket = Some(s)
            this.isConn = true
            return this.isConn
        }
    }

    /**
     * The Function is cleanUp
     *
     * @since 0.29.3
     */
    public func cleanUp() {
        // TOOD 关闭连接和流
        return
    }

    /**
     * The Function is run
     *
     * @return Type of ?ErrorCodes
     * @since 0.29.3
     */
    public func run(): ?ErrorCodes {
        let readIdleTimeout : Duration = Duration.nanosecond(0)
        var length = -1
        var errcode: ?ErrorCodes = None
        let framedecode = FramesDecoder()
        try {
            while (true) {
                length = this.socket.getOrThrow().read(connReadArray)
                let data = connReadArray[0..length]
                /* do hdaers frame and data frame */
                framedecode.decode(ByteBuffer(data))
                while(true) {
                    match (framedecode.getFrame()) {
                        case None => break
                        case Some(frame) => 
                            let isErr: Bool = match (errcode) {
                                case Some(v) => true
                                case None => false
                            }
                            if (isErr) {
                                return errcode
                            }
                            errcode = match (toFrameType(frame.getType())) {
                                case PING =>  processPing(frame)
                                case SETTINGS => processSettings(frame)
                                case GOAWAY => processGoAway(frame)
                                case HEADERS => processHeaders(frame)
                                case DATA => processData(frame)
                                case WINDOW_UPDATE => processWindowUpdate(frame)
                                case PUSH_PROMISE => processPushered(frame)
                                case _ => return PROTOCOL_ERROR
                            }
                    }

                } 
            }
        } catch (e: Exception) {
            return PROTOCOL_ERROR
        }
        return errcode
    }

    public func processPushered(pushed: Http2Frame): ?ErrorCodes {
        let conn = this.cc.getOrThrow()
        let stream = H2ClientStream(UInt32(pushed.getPromisedStream()), conn, ByteArrayStream())
        for (da in pushed.data) {
            let arr = conn.decode.decode(da.toArray())
            for (headerField in arr ) {
                if (headerField.name == ":path") {
                    let path = fs.Path(getcwd()).join(headerField.value)
                    stream.pushedFile = fs.File(path, CreateOrTruncate(true))
                }
                if (headerField.name == ":method") {
                    match (headerField.value) {
                        case "GET" | "Get" => stream.req = H2Request(GET, "")
                        case "HEAD" | "Head" => stream.req = H2Request(HEAD, "")
                        case _ => ()
                    }
                    
                }
            }
        }
        return None
    }

    public func processWindowUpdate(WindowUpdate: Http2Frame): ?ErrorCodes  {
        let conn = this.cc.getOrThrow()
        conn.conf.INITIAL_WINDOW_SIZE = WindowUpdate.windowUpdate
        return None
    }

    public func processHeaders(header: Http2Frame): ?ErrorCodes {
        try {
            this.cc.getOrThrow().streamMap[header.getStreamID()].resp.appendHeader(header)
            if ((header.getFlags() & 0x1) == 0x1) {
                this.cc.getOrThrow().streamMap[header.getStreamID()].rawCreatResponse()
                this.cc.getOrThrow().streamMap[header.getStreamID()].isEndStream.put("")
            }
            return None
        } catch (e: Exception) {
            e.printStackTrace()
            return PROTOCOL_ERROR
        }
    }

    public func processData(data: Http2Frame): ?ErrorCodes {
        try {
            this.cc.getOrThrow().streamMap[data.getStreamID()].resp.appendData(data)
            if ((data.getFlags() & 0x0) == 0x0) {
                let stream = this.cc.getOrThrow().streamMap[data.getStreamID()]
                stream.rawCreatResponse()
                if (data.getStreamID() % 2 == 0) {
                    let bytes = ArrayList<Byte>()
                    for (da in data.data) {
                        bytes.appendAll(da.toArray())
                    }
                    stream.pushedFile.getOrThrow().write(bytes.toArray())
                } else {
                    this.cc.getOrThrow().streamMap[data.getStreamID()].isEndStream.put("")
                }
            }
            return None
        } catch (e: Exception) {
            e.printStackTrace()
            return PROTOCOL_ERROR
        }
    }

    /*
        GOAWAY 帧适用于连接，而不是特定的流。端点
        必须将具有除 0x0 以外的流标识符的 GOAWAY 帧视为 PROTOCOL_ERROR 类型的连接错误(第 5.4.1 节)。
     */
    public func processGoAway(goaway: Http2Frame): ?ErrorCodes {
        try {
            if (goaway.getFlags() != 0x0) {
                return PROTOCOL_ERROR
            }
            let conn = this.cc.getOrThrow()
            // conn.ws.put(FrameFactory.getFactory().newGOAWAY(0, v, ""))
            conn.connState = CLOSE  // TODO
            return None
        } catch (e: Exception) {
            e.printStackTrace()
            return PROTOCOL_ERROR
        }
    }

    /**
     * The Function is processPing
     *
     * @param ping of Http2Frame
     * @param data of Array<UInt8>
     *
     * @return Type of ?ErrorCodes
     * @since 0.29.3
     */
    public func processPing(ping: Http2Frame): ?ErrorCodes {
        try {
            if (ping.getFlags() != 0x0) {
                throw Http2PingException()
            }
            let conn = this.cc.getOrThrow()
            ping.setFlags(0x1)
            conn.ws.put(ping)
            conn.connState = ConnStateTable.nextConnState(conn.connState, ConnConf.RECV_PING)
            return None
        } catch (e: Exception) {
            e.printStackTrace()
            return PROTOCOL_ERROR
        }
        
    }

    /**
     * The Function is processSettings
     *
     * @param settings of Http2Frame
     * @param data of Array<UInt8>
     *
     * @return Type of ?ErrorCodes
     * @since 0.29.3
     */
    public func processSettings(settings: Http2Frame): ?ErrorCodes {
        try{
            if (settings.getLength() % 6 != 0 && settings.getType() != 0x4) {
                return PROTOCOL_ERROR
            }
            if (settings.getFlags() != 0x0) {
                return None   // 对端发起的回应ACK
            }
            let conn = this.cc.getOrThrow()
            for (i in 0..settings.parameters.size where settings.parameters[i] != -1){
                match (i) {
                    case 0x0 => conn.conf.HEADER_TABLE_SIZE      = Int64(settings.parameters[i])
                    case 0x1 => conn.conf.ENABLE_PUSH            = Int64(settings.parameters[i])
                    case 0x2 => conn.conf.MAX_CONCURRENT_STREAMS = Int64(settings.parameters[i])
                    case 0x3 => conn.conf.INITIAL_WINDOW_SIZE    = Int64(settings.parameters[i])
                    case 0x4 => conn.conf.MAX_FRAME_SIZE         = Int64(settings.parameters[i])
                    case 0x5 => conn.conf.MAX_HEADER_LIST_SIZE   = Int64(settings.parameters[i])
                    case _ => throw Exception()
                }
            }
            conn.ws.put(frameFactory.newSETTINGS_ACK(0x1))
            conn.connState = ConnStateTable.nextConnState(conn.connState, ConnConf.RECV_SETTINGS)
            return None
        } catch (e: Exception) {
            e.printStackTrace()
            // reutrn PROTOCOL_ERROR
            throw e
        }
    }

}

/**
 * The class is H2ClientConnWriteLoop
 * @author liyanqing14
 * @since 0.29.3
 */
public open class H2ClientConnWriteLoop {
    protected var cc: ?H2ClientConn
    private var isConn: Bool 
    private var socket: ?SocketClient

    /**
     * The Function is init constructor
     *
     * @param cc of ?H2ClientConn
     * @param s of ?Socket
     * @since 0.29.3
     */
    public init (cc: ?H2ClientConn, s: ?SocketClient) {
        this.cc = cc
        this.socket = s
        this.isConn = match ((cc, s)) {
            case (Some(v), Some(w)) => true
            case _ => false
        }
    }

    /**
     * The Function is setClientConn
     *
     * @param cc of H2ClientConn
     * @param s of Socket
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func setClientConn(cc: H2ClientConn, s: SocketClient): Bool {
        if (this.isConn) {
            return !this.isConn
        } else {
            this.cc = Some(cc)
            this.socket = Some(s)
            this.isConn = true
            return this.isConn
        }
    }

    /**
     * The Function is run
     *
     * @since 0.29.3
     */
    public func run() {
        var isFirst: Bool = true
        let sendDataStack = LinkedList<Array<UInt8>>()
        // let client = this.cc.getOrThrow("not found client connection.")
        let client = this.cc.getOrThrow()
        while(true) {
            match (client.ws.poll()) {
                case Some(v) => 
                    if (isFirst) {
                        if (v.getType() != 0x4) {
                            sendDataStack.append(getUInt8FromFrames(v))
                        } else {
                            client.conn.write(getUInt8FromFrames(v))
                            isFirst = false
                        }
                    } else {
                        while (sendDataStack.size > 0) {
                            client.conn.write(sendDataStack.removeFirst())
                        }
                        client.conn.write(getUInt8FromFrames(v))
                        ()
                    }
                case None => 
                    while (sendDataStack.size > 0) {
                        client.conn.write(sendDataStack.removeFirst())
                    }
                    continue
            }
        }
    }

}



/**
 * The class is Flow
 * @author liyanqing14
 * @since 0.29.3
 */
public open class Flow {
    public var n: Int64
    public var conn: ?Flow

    /**
     * The Function is init constructor
     *
     * @since 0.29.3
     */
    public init() {
        this.n = 0
        this.conn = None
    }

    /**
     * The Function is init constructor
     *
     * @param n of Int64
     * @param conn of ?Flow
     * @since 0.29.3
     */
    public init(n: Int64, conn: ?Flow) {
        this.n = n
        this.conn = conn
    }

    /**
     * The Function is setConnFlow
     *
     * @param cf of Flow
     * @since 0.29.3
     */
    public func setConnFlow(cf: Flow) {
        this.conn = Some(cf)
    }

    /**
     * The Function is available
     *
     * @return Type of Int64
     * @since 0.29.3
     */
    public func available(): Int64 {
        return match(this.conn) {
            case Some(v) =>
                if (v.n < this.n) {
                    return v.n
                }
                return this.n
            case None => return this.n
        }
    }

    /**
     * The Function is take
     *
     * @param n of Int64
     * @since 0.29.3
     */
    public func take(n: Int64) {
        if (this.n > this.available()) {
            throw Exception("flow: took too much")
        }
        this.n -= n
        match (this.conn) {
            case Some(v) => v.n -= n
            case None => ()
        }
    }

    /**
     * The Function is add
     *
     * @param n of Int64
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    public func add(n : Int64): Bool {
        let sum = this.n + n
        if (this.n > 0 && n > 0 && sum < Int64(Int32.Max)) {
            this.n = sum
            return true
        }
        return false
    }
}
