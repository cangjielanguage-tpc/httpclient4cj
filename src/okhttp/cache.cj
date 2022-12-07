/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the Cache class.
 */
package okhttp

public class Cache {
    private static let VERSION: Int64 = 202212
    private static let ENTRY_COUNT: Int64 = 2
    private static let ENTRY_METADATA: Int64 = 0
    private static let ENTRY_BODY: Int64 = 1
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
            directory = Directory.create(directoryPath, recursive: ture)
        } else {
            directory = Directory(directoryPath)
        }

        this(directory, maxSize, FileSystem(directory))
    }

    init(directory: Directory, maxSize: Int64, fileSystem: FileSystem) {
        this.cache = DiskLruCache.create(fileSystem, directory, VERSION, ENTRY_COUNT, maxSize)
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

    }

    func trackConditionalCacheHit() {
         synchronized(lock) {
            hitCount++
        }
    }

    func get(request: Request): Response {
        let key = key(request.getUrl())
        var snapshot: Snapshot
        var entry: Entry
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
            entry = CacheEntry(snapshot.getSource(ENTRY_METADATA), this)
        } catch (e: Exception) {
            Util.closeQuietly(snapshot)
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

        if (hasVaryAll(response.getHeaders())) {
            return None
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
private class CacheEntry {
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
    
    init (in: OkBuffer) {
        try (r = in) {
            let urlString = source.readUtf8LineStrict()
            url = urlString
            requestMethod = source.readUtf8LineStrict()
            let varyRequestHeaderLineCount: Int64 = readInt(source)
            let varyHeaders: Header = Header()
            for (i in 0..varyRequestHeaderLineCount) {
                addLenient(varyHeaders, source.readUtf8LineStrict())
            }

            let statusLine: StatusLine = StatusLine.parse(source.readUtf8LineStrict())
            protocol = statusLine.protocol
            code = statusLine.code
            message = statusLine.message

            let responseHeader: Header = Header()
            let responseHeaderLineCount: Int64 = readInt(source)
            for (i in 0..varyRequestHeaderLineCount) {
                addLenient(responseHeader, source.readUtf8LineStrict())
            }
            let sendRequestMillisString: String = responseHeader.get(SENT_MILLIS).getOrThrow()
            let receivedResponseMillisString: String = responseHeader.get(RECEIVED_MILLIS)getOrThrow()

            sentRequestMillis = match (Int64.tryParse(sendRequestMillisString)) {
                case None => 0
                case Some(v) => v
            }

            receivedResponseMillis = match (Int64.tryParse(receivedResponseMillisString)) {
                case None => 0
                case Some(v) => v
            }
            responseHeaders.remove(SENT_MILLIS)
            responseHeaders.remove(RECEIVED_MILLIS)

            //if(urlString.startsWith("https://")) {

            //}
        }
    }

    public func response(snapshot: Snapshot): Response {
         let contentType: String = responseHeader.get("Content-Type").getOrThrow()
         let contentLength: String = responseHeader.get("Content-Length")getOrThrow()

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
            .headers(responseHeaders)
            .body(CacheResponseBody(snapshot, contentType, contentLength))
            .sentRequestAtMillis(sentRequestMillis)
            .receivedResponseAtMillis(receivedResponseMillis)
            .build()


    }

    private func readInt(source: OkBuffer): Int64 {
        return Int64(Int32(source.readByte()) << 24| Int32(source.readByte()) << 16 |
                Int32(source.readByte()) << 8 | Int32(source.readByte()))
    }

}

private class CacheResponseBody <: ResponseBody {
    let snapshot: Snapshot
    //TODO delete
    //private let bodySource: OkBuffer
    //private let contentLength: String
    
    init(snapshot: Snapshot, contentType: String, contentLength: String) {
         this.snapshot = snapshot
         let length = match(Int64.tryParse(contentLength)) {
            case Some(v) => v
            case None => -1
         }
         super(contentType, length, snapshot.getSource(ENTRY_BODY))
    }

}


public class CacheRequest{}