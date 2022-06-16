package okhttp
from std import io.*
from net import http.*

public class ResponseBody {
    var source: BufferStream

    public init(source: BufferStream)     {
        this.source = source
    }

    public func getSource(): BufferStream {
        return source
    }

    public func close() {
        Util.closeQuietly(source)
    }
}






