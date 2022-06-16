package okhttp

public class Util {

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