/**
 * @file
 * The file declares the Util class.
 */

package httpclient4cj

internal import stdx.compress.zlib.*
internal import stdx.crypto.crypto.*
internal import stdx.encoding.hex.*
internal import stdx.encoding.url.*
internal import stdx.log.*
internal import stdx.net.http.*
internal import stdx.net.http.CookieJar as HttpCookieJar
internal import stdx.net.tls.*
internal import stdx.net.tls.common.*
internal import std.collection.*
internal import std.collection.concurrent.ConcurrentHashMap
internal import std.convert.*
internal import std.fs.{Directory, File, FileInfo, FSException, OpenMode, Path}
internal import std.io.*
internal import std.math.*
internal import std.net.*
internal import std.random.*
internal import std.regex.*
internal import std.sync.*
internal import std.time.*
internal import std.unicode.*

let METHOD_GET = "GET"

/**
 * The class is Util
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
class Util {
    private static let VERIFY_AS_IP_ADDRESS = "([0-9a-fA-F]*:[0-9a-fA-F:.]*)|([\\d.]+)"

    /**
     * The Function is closeQuietly
     *
     * @param socket of Option<Socket>
     * @since 0.29.3
     */
    static func closeQuietly<T>(socket: Option<T>): Unit where T <: Resource {
        match (socket) {
            case Some(s) => try {
                if (!s.isClosed()) {
                    s.close()
                }
            } catch (ignored: Exception) {
                throw ignored
            }
            case None => ()
        }
    }

    /**
     * The Function is sameConnection
     *
     * @param a of URL
     * @param b of URL
     *
     * @return Type of Bool
     * @since 0.29.3
     */
    static func sameConnection(a: URL, b: URL): Bool {
        return a.hostName == b.hostName && a.port == b.port && a.scheme == b.scheme
    }

    static func skipUntil(input: String, pos: Int64, characters: String): Int64 {
        var posi: Int64 = pos

        while (posi < input.size) {
            let res: Int64 = characters.indexOf(input[Int64(posi)]) ?? -1
            if (res != -1) {
                break
            }
            posi++
        }

        return posi
    }

    static func skipWhitespace(input: String, pos: Int64): Int64 {
        var posi: Int64 = pos

        while (posi < input.size) {
            let c = input[posi]
            if (c != b' ' && c != b'\t') {
                break
            }
            posi++
        }

        return posi
    }

    static func parseSeconds(value: String, defaultValue: Int64): Int64 {
        try {
            let seconds: Int = Int64.parse(value)
            if (seconds < 0) {
                return 0
            } else {
                return seconds
            }
        } catch (e: Exception) {
            return defaultValue
        }
    }

    static func verifyAsIpAddress(host: String): Bool {
        match (Regex(VERIFY_AS_IP_ADDRESS).find(host)) {
            case Some(_) => return true
            case None => return false
        }
    }
}

func addLenient(header: Header, line: String) {
    match (line.indexOf(":", 1)) {
        case Some(index) => header.add(line.substring(0, index), line.substring(index + 1).trim())
        case None => if (!line.startsWith(":")) {
            header.add("", line)
        } else {
            throw ProtocolException("Unexpected header: ${line}")
        }
    }
}

/*
 * 快速裁剪响应头值：ASCII 空白走 trimAscii；仅当剩余边界出现非 ASCII 字节时才回退到
 * Unicode trim，保证与通用路径 trim()+trimAscii 的结果一致。
 */
func trimHeaderValue(raw: String): String {
    let v = raw.trimAscii()
    if (v.size > 0 && (v[0] >= 0x80u8 || v[v.size - 1] >= 0x80u8)) {
        return v.trim()
    }
    return v
}

/*
 * 快路径响应头解析：只裁剪一次值空白，避免通用 add 中的重复裁剪与重复哈希计算。
 */
func addLenientFast(header: Header, line: String) {
    match (line.indexOf(":", 1)) {
        case Some(index) => header.addResponseHeader(line.substring(0, index), trimHeaderValue(line.substring(index + 1)))
        case None => if (!line.startsWith(":")) {
            header.addResponseHeader("", line)
        } else {
            throw ProtocolException("Unexpected header: ${line}")
        }
    }
}

/*
 * The Function is receiveHeaders
 *
 * @param cookieJar of CookieJar
 * @param url of URL
 * @param header of Header
 *
 * @return Type of Unit
 * @since 0.29.3
 */
func receiveHeaders(cookieJar: CookieJar, url: URL, headers: Header): Unit {
    match (cookieJar) {
        case _: NoCookieJar => return
        case _ => ()
    }

    let cookies: ArrayList<Cookie> = CookieUtil.parseAll(url, headers)

    if (cookies.isEmpty()) {
        return
    }
    cookieJar.saveFromResponse(url, cookies.toArray())
}

func disCard(source: Source): Bool {
    try {
        let arr = ByteBuffer()
        while (source.read(arr, 4096) != -1) {
            arr.clear()
        }
        return true
    } catch (e: SocketTimeoutException) {
        return false
    }
}

func equalsIgnoreCase(left: String, right: String): Bool {
    if (left.size != right.size) {
        return false
    }
    let n = left.size
    var i = 0
    while (i < n) {
        let l = left[i]
        let r = right[i]
        if (l != r) {
            // HTTP 头/指令均为 ASCII；遇到非 ASCII 字节回退到原实现，保持 Unicode 大小写语义一致
            if (l >= 0x80u8 || r >= 0x80u8) {
                return left.toUpper() == right.toUpper()
            }
            let lowerL = if (l >= 0x41u8 && l <= 0x5Au8) { l + 0x20u8 } else { l }
            let lowerR = if (r >= 0x41u8 && r <= 0x5Au8) { r + 0x20u8 } else { r }
            if (lowerL != lowerR) {
                return false
            }
        }
        i++
    }
    return true
}

// 仅针对 ASCII 的小写转换：无需走 Unicode 大小写映射，且全小写输入零拷贝返回
func asciiLower(s: String): String {
    let n = s.size
    var i = 0
    var hasUpper = false
    while (i < n) {
        let b = s[i]
        if (b >= 0x80u8) {
            return s.toLower()
        }
        if (b >= 0x41u8 && b <= 0x5Au8) {
            hasUpper = true
        }
        i++
    }
    if (!hasUpper) {
        return s
    }
    let arr = s.toArray()
    i = 0
    while (i < n) {
        let b = arr[i]
        if (b >= 0x41u8 && b <= 0x5Au8) {
            arr[i] = b + 0x20u8
        }
        i++
    }
    return String.fromUtf8(arr)
}

// 大小写不敏感的 31 进制哈希，用于 Header 查找时先比哈希、再比字符串
@OverflowWrapping
func headerNameHash(name: String): Int64 {
    var h: Int64 = 0
    for (b in name) {
        var c = b
        if (c >= 0x41u8 && c <= 0x5Au8) {
            c = c + 0x20u8
        }
        h = h * 31 + Int64(c)
    }
    return h
}

func UInt64ToHexString(n: UInt64): Array<Byte> {
    var num: UInt64 = n
    var arrSize: Int64 = 0

    for (_ in 0..16) {
        if (num > 0) {
            arrSize++
            num = num >> 4
        } else {
            break
        }
    }

    var arr = Array<Byte>(arrSize, repeat: UInt8(CHAR_ZERO))
    var mask: UInt64 = 0x0f
    num = n

    for (i in arrSize - 1..-1 : -1) {
        if (num > 0) {
            var item = num & mask
            arr[i] = UInt64ToHex[Int64(item)]
            num = num >> 4
        } else {
            break
        }
    }
    return arr
}

func HexStringToUInt64(arr: Array<Byte>): Option<UInt64> {
    var arrSize = arr.size
    var num: UInt64 = 0

    for (i in 0..arrSize) {
        var b = arr[i]
        if (b'0' <= b && b <= b'9') {
            b = b - b'0'
        } else if (b'a' <= b && b <= b'f') {
            b = b - (b'a' - 10)
        } else if (b'A' <= b && b <= b'F') {
            b = b - (b'A' - 10)
        } else {
            return None
        }
        num = num * 16 + UInt64(b)
    }
    return Some(num)
}

func has<T>(op: Option<T>): Bool {
    match (op) {
        case Some(_) => return true
        case None => return false
    }
}

extend Int64 {
    operator func >=(right: UInt16): Bool {
        this >= Int64(right)
    }
    operator func !=(right: UInt16): Bool {
        this != Int64(right)
    }
    operator func ==(right: UInt16): Bool {
        this == Int64(right)
    }
    operator func <(right: UInt16): Bool {
        this < Int64(right)
    }
}

extend Cookie {
    prop name: String {
        get() {
            this.cookieName
        }
    }
    prop value: String {
        get() {
            this.cookieValue
        }
    }
}

extend Header {
    public func clone(): Header {
        // 惰性头只共享不可变原始文本；两边各自物化，互不污染
        match (lazyPending) {
            case Some(pending) => if (pending.load()) {
                return Header(rawHeaders.getOrThrow())
            }
            case None => ()
        }
        // 写时复制：克隆只共享底层存储，任一实例发生修改时才真正拷贝，避免每个请求多次深拷贝
        let dest = Header()
        dest.names = this.names
        dest.values = this.values
        dest.hashes = this.hashes
        dest.table = this.table
        dest.fieldNames = this.fieldNames
        dest.fieldValues = this.fieldValues
        dest.shared = true
        dest.modCount = this.modCount
        this.shared = true
        return dest
    }
    public func remove(k: String): Unit {
        this.del(k)
    }
    public func getString(k: String): ?String {
        let i = findIndex(k)
        if (i >= 0) {
            let v = values[i]
            if (v.size == 1) {
                return v[0]
            }
            return v |> collectString<String>(delimiter: "; ")
        }
        let fi = findFieldIndex(k)
        if (fi >= 0) {
            let v = fieldValues[fi]
            if (v.size == 1) {
                return v[0]
            }
            return v |> collectString<String>(delimiter: "; ")
        }
        return None
    }
    public func getAll(k: String): ArrayList<String> {
        this.get(k) ?? ArrayList()
    }
}

/**
 * HTTP 头容器：名字大小写不敏感、保持插入顺序；克隆采用写时复制。
 */
public class Header <: Iterable<(String, ArrayList<String>)> {
    // 非伪头：名字 + 对应的值列表，names/values 按下标一一对应
    var names: ArrayList<String> = ArrayList<String>()
    var values: ArrayList<ArrayList<String>> = ArrayList<ArrayList<String>>()
    var hashes: ArrayList<Int64> = ArrayList<Int64>()
    // 头数 >= 16 时启用的开放寻址表（哈希 -> 下标+1，0 为空）；少于 16 个时走线性扫描
    var table: Array<Int64> = Array<Int64>(0, repeat: 0)
    // 伪头（HTTP/2 的 ":xxx"），沿用独立存储，避免为普通 header 分配哈希表
    var fieldNames: ArrayList<String> = ArrayList<String>(0)
    var fieldValues: ArrayList<ArrayList<String>> = ArrayList<ArrayList<String>>(0)
    // 是否与其它 Header 实例共享底层存储
    var shared: Bool = false
    // 修改计数：供 Request 快路径序列化缓存判断是否需要失效
    var modCount: Int64 = 0
    // 惰性头：保留不可变原始头块，首次访问时在锁内物化并原子发布
    var rawHeaders: Option<String> = Option<String>.None
    // None=eager；Some 仅在惰性头物化完成前为 true，物化后保留 Some(false) 供 acquire 发布
    var lazyPending: Option<AtomicBool> = Option<AtomicBool>.None
    private static let LAZY_LOCK: Mutex = Mutex()

    public init() {}
    init(raw: String) {
        this.rawHeaders = Option<String>.Some(raw)
        this.lazyPending = Option<AtomicBool>.Some(AtomicBool(true))
    }
    init(fields: Array<HeaderField>) {
        for (f in fields) {
            this.set(f.name, toValueArr(f.value))
        }
    }
    private func toValueArr(value: String): ArrayList<String> {
        value.split(";") |> map {s: String => s.trim()} |> collectArrayList
    }
    /**
     * 惰性物化：解析到临时 Header，成功后在锁内一次性发布，避免并发读到半成品。
     */
    private func materialize(): Unit {
        let pending = match (lazyPending) {
            case Some(v) => v
            case None => return
        }
        if (!pending.load()) {
            return
        }
        synchronized(LAZY_LOCK) {
            if (!pending.load()) {
                return
            }
            let text = match (rawHeaders) {
                case Some(v) => v
                case None => ""
            }
            let parsed = Header()
            var pos = 0
            while (true) {
                let next = match (text.indexOf("\r\n", pos)) {
                    case Some(v) => v
                    case None => break
                }
                if (next > pos) {
                    addLenientFast(parsed, text.substring(pos, next - pos))
                }
                pos = next + 2
            }
            if (pos < text.size) {
                addLenientFast(parsed, text.substring(pos))
            }
            names = parsed.names
            values = parsed.values
            hashes = parsed.hashes
            table = parsed.table
            fieldNames = parsed.fieldNames
            fieldValues = parsed.fieldValues
            shared = false
            modCount = 0
            rawHeaders = Option<String>.None
            pending.store(false)
        }
    }
    // 头数量通常很小（几个到几十个），线性大小写不敏感查找比哈希 + 小写化分配更快
    func findIndex(name: String): Int64 {
        return findIndexByHash(name, headerNameHash(name))
    }
    func findIndexByHash(name: String, h: Int64): Int64 {
        materialize()
        if (names.size < 16) {
            for (i in 0..names.size) {
                if (hashes[i] == h && equalsIgnoreCase(names[i], name)) {
                    return i
                }
            }
            return -1
        }
        let mask = table.size - 1
        var slot = h % table.size
        if (slot < 0) {
            slot += table.size
        }
        while (true) {
            let v = table[slot]
            if (v == 0) {
                return -1
            }
            let i = v - 1
            if (hashes[i] == h && equalsIgnoreCase(names[i], name)) {
                return i
            }
            slot = (slot + 1) & mask
        }
        return -1
    }
    private func tableInsert(h: Int64, idx: Int64): Unit {
        let mask = table.size - 1
        var slot = h % table.size
        if (slot < 0) {
            slot += table.size
        }
        while (table[slot] != 0) {
            slot = (slot + 1) & mask
        }
        table[slot] = idx + 1
    }
    private func rebuildTable(newSize: Int64): Unit {
        table = Array<Int64>(newSize, repeat: 0)
        for (i in 0..names.size) {
            tableInsert(hashes[i], i)
        }
    }
    // 伪头按原始名字精确匹配（与原有 fields 哈希表语义一致）
    func findFieldIndex(name: String): Int64 {
        materialize()
        for (i in 0..fieldNames.size) {
            if (fieldNames[i] == name) {
                return i
            }
        }
        return -1
    }
    private func ensureOwned(): Unit {
        materialize()
        if (!shared) {
            return
        }
        let newNames = ArrayList<String>(names.size)
        let newValues = ArrayList<ArrayList<String>>(values.size)
        let newHashes = ArrayList<Int64>(hashes.size)
        for (i in 0..names.size) {
            newNames.add(names[i])
            newValues.add(values[i].clone())
            newHashes.add(hashes[i])
        }
        if (names.size >= 16) {
            let t = table.clone()
            table = t
        }
        let newFieldNames = ArrayList<String>(fieldNames.size)
        let newFieldValues = ArrayList<ArrayList<String>>(fieldValues.size)
        for (i in 0..fieldNames.size) {
            newFieldNames.add(fieldNames[i])
            newFieldValues.add(fieldValues[i].clone())
        }
        names = newNames
        values = newValues
        hashes = newHashes
        fieldNames = newFieldNames
        fieldValues = newFieldValues
        shared = false
    }
    public func add(name: String, value: String): Unit {
        if (name.startsWith(":")) {
            let valueTrim = value.trim()
            let i = findFieldIndex(name)
            ensureOwned()
            modCount++
            if (i >= 0) {
                fieldValues[i].add(valueTrim)
            } else {
                fieldNames.add(name)
                let list = ArrayList<String>()
                list.add(valueTrim)
                fieldValues.add(list)
            }
        } else {
            let valueTrim = value.trimAscii()
            if (!checkHeaderField(name, valueTrim)) {
                return
            }
            let i = findIndex(name)
            ensureOwned()
            modCount++
            if (i >= 0) {
                values[i].add(valueTrim)
            } else {
                let h = headerNameHash(name)
                names.add(asciiLower(name))
                hashes.add(h)
                if (names.size == 16) {
                    rebuildTable(32)
                } else if (names.size > 16) {
                    if (names.size * 10 >= table.size * 7) {
                        rebuildTable(table.size * 2)
                    } else {
                        tableInsert(h, names.size - 1)
                    }
                }
                let list = ArrayList<String>()
                list.add(valueTrim)
                values.add(list)
            }
        }
    }

    /**
     * 快路径响应头写入：值已由调用方裁剪空白，复用一次计算出的名字哈希；
     * 校验规则与通用 add 保持一致。
     */
    func addResponseHeader(name: String, value: String): Unit {
        if (name.startsWith(":")) {
            add(name, value)
            return
        }
        if (!checkHeaderField(name, value)) {
            return
        }
        let h = headerNameHash(name)
        let i = findIndexByHash(name, h)
        ensureOwned()
        modCount++
        if (i >= 0) {
            values[i].add(value)
        } else {
            names.add(asciiLower(name))
            hashes.add(h)
            if (names.size == 16) {
                rebuildTable(32)
            } else if (names.size > 16) {
                if (names.size * 10 >= table.size * 7) {
                    rebuildTable(table.size * 2)
                } else {
                    tableInsert(h, names.size - 1)
                }
            }
            let list = ArrayList<String>(1)
            list.add(value)
            values.add(list)
        }
    }
    public func set(name: String, value: ArrayList<String>): Unit {
        if (name.startsWith(":")) {
            let i = findFieldIndex(name)
            ensureOwned()
            modCount++
            if (i >= 0) {
                fieldValues[i] = value
            } else {
                fieldNames.add(name)
                fieldValues.add(value)
            }
        } else {
            this.del(name)
            for (v in value) {
                this.add(name, v)
            }
        }
    }
    public func get(name: String): ?ArrayList<String> {
        let i = findIndex(name)
        if (i >= 0) {
            return values[i].clone()
        }
        let fi = findFieldIndex(name)
        if (fi >= 0) {
            return fieldValues[fi]
        }
        return None
    }
    public func del(name: String): Unit {
        let fi = findFieldIndex(name)
        let i = findIndex(name)
        if (fi < 0 && i < 0) {
            return
        }
        ensureOwned()
        if (fi >= 0) {
            fieldNames.remove(at: fi)
            fieldValues.remove(at: fi)
        }
        if (i >= 0) {
            names.remove(at: i)
            values.remove(at: i)
            hashes.remove(at: i)
            if (names.size >= 16) {
                rebuildTable(table.size)
            }
        }
        modCount++
    }
    public func iterator(): Iterator<(String, ArrayList<String>)> {
        materialize()
        HeaderIterator(this)
    }
    // 内部只读遍历：不拷贝值列表，供 writeRequest 等只读热点使用
    func fieldCount(): Int64 {
        materialize()
        return names.size + fieldNames.size
    }
    func fieldNameAt(i: Int64): String {
        materialize()
        if (i < names.size) {
            return names[i]
        }
        return fieldNames[i - names.size]
    }
    func fieldValuesAt(i: Int64): ArrayList<String> {
        materialize()
        if (i < names.size) {
            return values[i]
        }
        return fieldValues[i - names.size]
    }
}

class HeaderIterator <: Iterator<(String, ArrayList<String>)> {
    private let header: Header
    private var i: Int64 = 0
    private var fi: Int64 = 0

    init(header: Header) {
        this.header = header
    }

    public func next(): Option<(String, ArrayList<String>)> {
        if (i < header.names.size) {
            let name = header.names[i]
            let vals = header.values[i].clone()
            i++
            return (name, vals)
        }
        if (fi < header.fieldNames.size) {
            let name = header.fieldNames[fi]
            let vals = header.fieldValues[fi]
            fi++
            return (name, vals)
        }
        return None
    }
}

func isHttpTokenByte(b: Byte): Bool {
    if ((b >= 0x30u8 && b <= 0x39u8) || (b >= 0x41u8 && b <= 0x5Au8) || (b >= 0x61u8 && b <= 0x7Au8)) {
        return true
    }
    return b == 0x21u8 || b == 0x23u8 || b == 0x24u8 || b == 0x25u8 || b == 0x26u8 || b == 0x27u8 ||
        b == 0x2Au8 || b == 0x2Bu8 || b == 0x2Du8 || b == 0x2Eu8 || b == 0x5Eu8 || b == 0x5Fu8 ||
        b == 0x60u8 || b == 0x7Cu8 || b == 0x7Eu8
}

// 与 stdx.net.http.HttpHeaders.add 的校验行为保持一致
func checkHeaderField(name: String, value: String): Bool {
    if (name.isEmpty()) {
        throw HttpException("Invalid header name: ${name}.")
    }
    for (b in name) {
        if (!isHttpTokenByte(b)) {
            throw HttpException("Invalid header name: ${name}.")
        }
    }
    if (value.isEmpty()) {
        return false
    }
    for (b in value) {
        if ((b < 0x20u8 && b != 0x09u8) || b == 0x7Fu8) {
            throw HttpException("Invalid header value: ${value}.")
        }
    }
    return true
}

foreign func htons(port: UInt16): UInt16
public func portTrans(port: UInt16): UInt16 {
    // unsafe { htons(port) }
    port
}

let LOG: Logger = getGlobalLogger()


extend String {
    func equals(s: String): Bool {
        this == s
    }
    func toUtf8Array(): Array<UInt8> {
        this.toArray()
    }
    func substring(start: Int64, size: Int64): String {
        this[start..start + size]
    }
    func substring(start: Int64): String {
        this[start..]
    }
    func contains(char: Rune): Bool {
        this.contains(char.toString())
    }
}
extend UInt8 {
    operator func ==(char: Rune): Bool {
        UInt32(this) == UInt32(char)
    }
}
