/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the Cache class.
 */
package okhttp


let VERSION: Int64 = 202212
let ENTRY_COUNT: Int64 = 2
let ENTRY_METADATA: Int64 = 0
let ENTRY_BODY: Int64 = 1

let CLEAN: String = "CLEAN"
let DIRTY: String = "DIRTY"
let REMOVE: String = "REMOVE"
let READ: String = "READ"
let JOURNAL_FILE: String = "journal"
let JOURNAL_FILE_TEMP: String = "journal.tmp"
let JOURNAL_FILE_BACKUP: String = "journal.bkp"
let VERSION_1: String = "1"
let ANY_SEQUENCE_NUMBER = -1
let MAGIC: String = "libcore.io.DiskLruCache"

public class Cache {
    let cache: DiskLruCache
    let lock: Monitor = Monitor()

    private var requestCount: Int64 = 0
    private var hitCount: Int64 = 0
    private var writeSuccessCount: Int64 = 0
    private var writeAbortCount: Int64 = 0
    private var networkCount: Int64 = 0


    public init(directoryPath: String, maxSize: Int64) {
        let directory: Directory
        if (!Directory.exists(directoryPath)) {
            directory = Directory.create(directoryPath, recursive: true)
        } else {
            directory = Directory(directoryPath)
        }
        this.cache = DiskLruCache.create(FileSystem(directory), directory, VERSION, ENTRY_COUNT, maxSize)
    }


    func trackResponse(cacheStrategy: CacheStrategy) {
        synchronized(lock) {
             requestCount++
             if (has(cacheStrategy.networkRequest)) {
                networkCount++
             } else if(has(cacheStrategy.cacheResponse)) {
                hitCount++
             }
         }
    }

    func update(cached: Response, network: Response): Unit {
         var entry: CacheEntry = CacheEntry(network)
         let snapshot: Snapshot  = match (cached.getBody().getOrThrow()) {
            case cacheBody: CacheResponseBody =>
                    cacheBody.snapshot
            case _ => throw IllegalArgumentException("response has no cacheBody")
         }
         var editor: Option<Editor> = None
         try {
            editor = snapshot.edit()
            match (editor) {
                case Some(e) =>
                    entry.writeTo(e)
                    e.commit()
                case None => ()
            }
         } catch (e: FSException) {
            abortQuietly(editor)
         }
    }

    private func abortQuietly(editor: Option<Editor>) {
        try {
            match (editor) {
                case Some(e) => e.abort()
                case None => ()
            }
        } catch (ignored: Exception) {

        }
    }

    func trackConditionalCacheHit() {
         synchronized(lock) {
            hitCount++
        }
    }

    func get(request: Request): Option<Response> {
        let key = key(request.getUrl())
        var snapshot: Snapshot
        var entry: CacheEntry
        try {
            match (cache.get(key)) {
                case None =>
                    return Option<Response>.None
                case Some(v) =>
                    snapshot = v
            }
        } catch (e: Exception) {
            return Option<Response>.None
        }

        try {
            entry = CacheEntry(snapshot.getSource(ENTRY_METADATA))
        } catch (e: Exception) {
            Util.closeQuietly(snapshot)
            return Option<Response>.None
        }

        let response: Response = entry.response(snapshot)
        return response
    }

    func put(response: Response): Option<CacheRequest> {
        let requestMethod = response.getRequest().getMethod()
        if (invalidatesCache(requestMethod)) {
            try {
                remove(response.getRequest())
            } catch (ignored: HttpException) {

            }
            return None
        }

        if (requestMethod != "GET") {
            // Don't cache non-GET responses. We're technically allowed to cache
            // HEAD requests and some POST requests, but the complexity of doing
            // so is high and the benefit is low.
            return None
        }

        if (HttpHeaders.hasVaryAll(response.getHeaders())) {
            return None
        }

        let entry: CacheEntry = CacheEntry(response)
        let editor: Option<Editor>
        try {
            editor = cache.edit(key(response.getRequest().getUrl()))
            if (!has(editor)) {
                return None
            }
            let realEditor = editor.getOrThrow()
            entry.writeTo(realEditor)
            return CacheRequest(realEditor, this)
        } catch (e: IOException) {
            //TODO abort
        }


        //TODO LRU
        return Option<CacheRequest>.None
    }

    func key(url: URL) {
        return url.toString()
    }

    func remove(request: Request) {
        cache.remove(key(request.getUrl()))
    }


}

class CacheEntry {
    /** Synthetic response header: the local time when the request was sent. */
    private static let SENT_MILLIS = "OkHttp-Sent-Millis";

    /** Synthetic response header: the local time when the response was received. */
    private static let RECEIVED_MILLIS = "OkHttp-Received-Millis"

    private let url: String
    private let varyHeaders: Header
    private let requestMethod: String
    private let protocol: Protocol
    private let code: Int64
    private let message: String
    private let responseHeaders: Header
    private let sentRequestMillis: Int64
    private let receivedResponseMillis: Int64

    init (response: Response) {
        this.url = response.getRequest().getUrl().toString()
        this.varyHeaders = HttpHeaders.varyHeaders(response)
        this.requestMethod = response.getRequest().getMethod()
        this.protocol = response.getProtocol()
        this.code = response.getCode()
        this.message = response.getMessage()
        this.responseHeaders = response.getHeaders()
        this.sentRequestMillis = response.getSentRequestAtMillis()
        this.receivedResponseMillis = response.getReceivedResponseAtMillis()
    }
    
    init (source: OkBuffer) {
        try {
            let urlString = source.readUtf8LineStrict()
            url = urlString
            requestMethod = source.readUtf8LineStrict()
            let varyRequestHeaderLineCount: Int64 = Int64(Int32(source.readByte()) << 24| Int32(source.readByte()) << 16
                 | Int32(source.readByte()) << 8 | Int32(source.readByte()))
            let varyHeader: Header = Header()
            for (i in 0..varyRequestHeaderLineCount) {
                addLenient(varyHeader, source.readUtf8LineStrict())
            }
            this.varyHeaders = varyHeader
            let statusLine: StatusLine = StatusLine.parse(source.readUtf8LineStrict())
            protocol = statusLine.protocol
            code = statusLine.code
            message = statusLine.message

            let responseHeader: Header = Header()
            let responseHeaderLineCount: Int64 = Int64(Int32(source.readByte()) << 24| Int32(source.readByte()) << 16
                | Int32(source.readByte()) << 8 | Int32(source.readByte()))
            for (i in 0..varyRequestHeaderLineCount) {
                addLenient(responseHeader, source.readUtf8LineStrict())
            }
            let sendRequestMillisString: String = responseHeader.get(SENT_MILLIS).getOrThrow()
            let receivedResponseMillisString: String = responseHeader.get(RECEIVED_MILLIS).getOrThrow()

            sentRequestMillis = match (Int64.tryParse(sendRequestMillisString)) {
                case None => 0
                case Some(v) => v
            }

            receivedResponseMillis = match (Int64.tryParse(receivedResponseMillisString)) {
                case None => 0
                case Some(v) => v
            }
            responseHeader.remove(SENT_MILLIS)
            responseHeader.remove(RECEIVED_MILLIS)
            responseHeaders = responseHeader

            //TODO https
            //if(urlString.startsWith("https://")) {

            //}
        } finally {
            source.close()
        }
    }

    public func response(snapshot: Snapshot): Response {
         let contentType: String = responseHeaders.get("Content-Type").getOrThrow()
         let contentLength: String = responseHeaders.get("Content-Length").getOrThrow()

         let cacheRequest: Request = Request.builder()
            .url(url)
            .method(requestMethod)
            .header(varyHeaders)
            .build()

         return Response.builder()
            .request(cacheRequest)
            .protocol(protocol)
            .code(code)
            .message(message)
            .header(responseHeaders)
            .body(CacheResponseBody(snapshot, contentType, contentLength))
            .sentRequestAtMillis(sentRequestMillis)
            .receivedResponseAtMillis(receivedResponseMillis)
            .build()


    }


    public func writeTo(editor: Editor): Unit {
        let sink = editor.newSink(ENTRY_METADATA)
        sink.write(url.toUtf8Array())
        sink.write("\n".toUtf8Array())
        sink.write(requestMethod.toUtf8Array())
        sink.write("\n".toUtf8Array())
        //sink.write("${varyHeaders.getAll().size()}".toUtf8Array())
        var size = 0
        let list: ArrayList<Byte> = ArrayList<Byte>()
        for ((k, v) in varyHeaders) {
            size++
            list.appendAll(k.toUtf8Array())
            list.appendAll(": ".toUtf8Array())
            list.appendAll(v[0].toUtf8Array())
            list.appendAll("\n".toUtf8Array())
            //sink.write(k.toUtf8Array())
            //sink.write(": ".toUtf8Array())
            //sink.write(v[0].toUtf8Array())
            //sink.write("\n".toUtf8Array())
        }
        sink.write("${size}".toUtf8Array())
        sink.write(list.toArray())
        list.clear
        size = 0


        sink.write("${StatusLine(protocol, code, message)}".toUtf8Array())
        sink.write("\n".toUtf8Array())
        //sink.write("${responseHeaders.getAll().size() + 2 }".toUtf8Array())
        sink.write("\n".toUtf8Array())
        for ((k, v) in responseHeaders) {
            size++
            for(i in 0..v.size) {
                list.appendAll(k.toUtf8Array())
                list.appendAll(": ".toUtf8Array())
                list.appendAll(v[i].toUtf8Array())
                list.appendAll("\n".toUtf8Array())
                //sink.write(k.toUtf8Array())
                //sink.write(": ".toUtf8Array())
                //sink.write(v[i].toUtf8Array())
                //sink.write("\n".toUtf8Array())
            }
        }
        sink.write("${size + 2}".toUtf8Array())
        sink.write(list.toArray())
        sink.write(SENT_MILLIS.toUtf8Array())
        sink.write(": ".toUtf8Array())
        sink.write("${sentRequestMillis}".toUtf8Array())
        sink.write("\n".toUtf8Array())
        sink.write(RECEIVED_MILLIS.toUtf8Array())
        sink.write(": ".toUtf8Array())
        sink.write("${receivedResponseMillis}".toUtf8Array())
        sink.write("\n".toUtf8Array())
        //if (isHttps()) {

       // }
        sink.write(SENT_MILLIS.toUtf8Array())
        sink.write(SENT_MILLIS.toUtf8Array())
        //TODO https
        sink.close()
    }

}

class CacheResponseBody <: ResponseBody {
    let snapshot: Snapshot
    //TODO delete
    //private let bodySource: OkBuffer
    //private let contentLength: String
    
    init(snapshot: Snapshot, contentType: String, contentLength: String) {
         super(contentType, match(Int64.tryParse(contentLength)) {
            case Some(v) => v
            case None => -1
         }, snapshot.getSource(ENTRY_BODY))
         this.snapshot = snapshot
    }

}


public class CacheRequest {
    private let editor: Editor
    private let cache: Cache

    init(editor: Editor, cache: Cache) {
        this.editor = editor
        this.cache = cache
    }

}