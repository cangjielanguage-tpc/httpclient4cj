/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the HeaderField class.
 */

package okhttp


/**
 * The type Header field.
 */
struct HeaderField {
   var name: String
   var value: String
   var sensitive: Bool

    /**
     * Instantiates a new Init.
     *
     * @param n of String
     * @param v of String
     * @param s of Bool
     * @since 0.35.6
     */
    init(name: String, value: String, sensitive: Bool) {
        this.name = name
        this.value = value
        this.sensitive = sensitive
    }

    /**
     * Instantiates a new Init.
     *
     * @param n of String
     * @param v of String
     * @since 0.35.6
     */
    init(name: String, value: String) {
        this.name = name
        this.value = value
        this.sensitive = false
    }

    /**
     * Instantiates a new Init.
     *
     * @param n of String
     * @param s of Bool
     * @since 0.35.6
     */
    init(name: String, sensitive: Bool) {
        this.name = name
        this.value = ""
        this.sensitive = sensitive
    }

    /**
     * Instantiates a new Init.
     *
     * @param n of String
     * @since 0.35.6
     */
    init(name: String) {
        this.name = name
        this.value = ""
        this.sensitive = false
    }

    /**
     * Size func.
     *
     * @return Type of Int64
     * @since 0.35.6
     */
    func size(): Int64{
        return this.name.size + this.value.size + CONST_32_I64
    }

    
    func isPseudo(): Bool {
        return this.name.size != 0 && this.name[0] == ':'
    }
}

/**
 * The type Header static table.
 */
class HeaderStaticTable {
    static let capacity: Int64 = 61
    private static let staticTable: Array<HeaderField> =
        [
            /* 1 */HeaderField(":authority"),
            /* 2 */HeaderField(":method", "GET"),
            /* 3 */HeaderField(":method", "POST"),
            /* 4 */HeaderField(":path", "/"),
            /* 5 */HeaderField(":path", "/index.html"),
            /* 6 */HeaderField(":scheme", "http"),
            /* 7 */HeaderField(":scheme", "https"),
            /* 8 */HeaderField(":status", "200"),
            /* 9 */HeaderField(":status", "204"),
            /* 10 */HeaderField(":status", "206"),
            /* 11 */HeaderField(":status", "304"),
            /* 12 */HeaderField(":status", "400"),
            /* 13 */HeaderField(":status", "404"),
            /* 14 */HeaderField(":status", "500"),
            /* 15 */HeaderField("accept-charset"),
            /* 16 */HeaderField("accept-encoding", "gzip, deflate"),
            /* 17 */HeaderField("accept-language"),
            /* 18 */HeaderField("accept-ranges"),
            /* 19 */HeaderField("accept"),
            /* 20 */HeaderField("access-control-allow-origin"),
            /* 21 */HeaderField("age"),
            /* 22 */HeaderField("allow"),
            /* 23 */HeaderField("authorization"),
            /* 24 */HeaderField("cache-control"),
            /* 25 */HeaderField("content-disposition"),
            /* 26 */HeaderField("content-encoding"),
            /* 27 */HeaderField("content-language"),
            /* 28 */HeaderField("content-length"),
            /* 29 */HeaderField("content-location"),
            /* 30 */HeaderField("content-range"),
            /* 31 */HeaderField("content-type"),
            /* 32 */HeaderField("cookie"),
            /* 33 */HeaderField("date"),
            /* 34 */HeaderField("etag"),
            /* 35 */HeaderField("expect"),
            /* 36 */HeaderField("expires"),
            /* 37 */HeaderField("from"),
            /* 38 */HeaderField("host"),
            /* 39 */HeaderField("if-match"),
            /* 40 */HeaderField("if-modified-since"),
            /* 41 */HeaderField("if-none-match"),
            /* 42 */HeaderField("if-range"),
            /* 43 */HeaderField("if-unmodified-since"),
            /* 44 */HeaderField("last-modified"),
            /* 45 */HeaderField("link"),
            /* 46 */HeaderField("location"),
            /* 47 */HeaderField("max-forwards"),
            /* 48 */HeaderField("proxy-authenticate"),
            /* 49 */HeaderField("proxy-authorization"),
            /* 50 */HeaderField("range"),
            /* 51 */HeaderField("referer"),
            /* 52 */HeaderField("refresh"),
            /* 53 */HeaderField("retry-after"),
            /* 54 */HeaderField("server"),
            /* 55 */HeaderField("set-cookie"),
            /* 56 */HeaderField("strict-transport-security"),
            /* 57 */HeaderField("transfer-encoding"),
            /* 58 */HeaderField("user-agent"),
            /* 59 */HeaderField("vary"),
            /* 60 */HeaderField("via"),
            /* 61 */HeaderField("www-authenticate")
        ]

    /**
     * Get index func.
     *
     * @return the HeaderField
     */
    static func getIndex(index: Int64): HeaderField {
        if (index <= 0 || index > staticTable.size) {
            throw IndexOutOfBoundsException()
        }
        return staticTable[index - 1]
    }

    /**
     * Get index name func.
     *
     * @return the String
     */
    /* return */
    static func getIndexName(index: Int64): String {
        if (index <= 0 || index > staticTable.size) {
            throw IndexOutOfBoundsException()
        }
        
        return staticTable[index - 1].name
    }

    /**
     * Search name func.
     *
     * @return the Int64
     */
    private static func searchName(name: String): Int64 {
        for (i in 0..capacity where name.equals(staticTable[i].name)) {
            return i + 1
        }
        
        return -1
    }

    /**
     * Search func.
     *
     * @return the Int64
     */
    static func search(f: HeaderField): Int64 {
        let index: Int64 = searchName(f.name)
        
        if (index > capacity || index <= 0) {
            return -1
        }
        
        for (i in index..=capacity where f.name.equals(staticTable[i - 1].name) && f.value.equals(staticTable[i - 1].value)) {
            return i
        }
        
        return index
    }

    /**
     * Search full func.
     *
     * @return the Int64 * Int64
     */
     static func searchFull(f: HeaderField): (Int64, Int64) {
        let index = searchName(f.name)
        
        if (index > capacity || index <= 0) {
            return (-1, -1)
        }
        
        var key = index
        var value = -1
        
        for (i in index..=capacity where f.name.equals(staticTable[i - 1].name) && f.value.equals(staticTable[i - 1].value)) {
            key = i
            value = i
        }
        
        return (key, value)
    }
}


/**
 * The extend HeaderField.
 */
extend HeaderField <: ToString {
    /**
     * The Function is toString
     *
     * @return Type of String
     * @since 0.29.3
     */
    public func toString(): String {
        return "${this.name}: ${this.value}"
    }
}

let MAX_INT: Int64 = 0xFFFFFFFF
let MIN_INT: Int64 = 0

/**
 * The type Dynamic tables.
 *
 * Dynamic table size = (sum of bytes per Header +32) * number of key-value pairs
 */
class DynamicTables {
    protected var dynamicArray: Array<(Bool, Option<HeaderField>)>
    protected static let NULL: (Bool, Option<HeaderField>) = (false, None)
    protected var tail: Int64
    protected var head: Int64
    protected var myCapacity: Int64
    protected var mySize: Int64

    /**
     * Instantiates a new Init.
     */
     init (bs: Int64) {
        if (bs < MIN_INT || bs > MAX_INT) {
            throw IndexOutOfBoundsException("invalid value: ${bs}")
        }
        this.myCapacity = bs
        var maxEntries: Int64 = bs / CONST_32_I64
        if ((bs - CONST_32_I64 * maxEntries) != 0) {
            maxEntries++
        }
        this.dynamicArray = Array<(Bool, Option<HeaderField>)>(maxEntries, item: NULL)
        this.head = 0
        this.tail = 0
        this.mySize = 0
        this.myCapacity = bs
    }

    /**
     * Size func.
     *
     * @return the Int64
     */
    func size() : Int64 {
        return mySize
    }

    /**
     * Capacity func.
     *
     * @return the Int64
     */
    func capacity() : Int64 {
        return myCapacity
    }

    /**
     * Length func.
     *
     * @return the Int64
     */
     func length() : Int64 {
        return if (this.head < this.tail) {
            dynamicArray.size + head - tail
        } else {
            head - tail
        }
    }

    /**
     * Add func.
     * It is not an error to try to add an entry larger than the maximum size;
     * Attempting to add an entry larger than the maximum size causes the table to
     * empty all existing entries and results in an empty table.
     *
     * @return the Unit
     */
    public func add(header: HeaderField): Unit {
        let headerSize: Int64 = header.size();
        if (headerSize > this.myCapacity) {
            this.clear()
            return
        }
        while (this.myCapacity - this.mySize < headerSize) {
            this.remove()
        }
        this.dynamicArray[head] = (true, header);
        this.head++
        this.mySize += headerSize;
        if (this.head == dynamicArray.size) {
            this.head = 0;
        }
    }

    /**
     * Get entry func.
     *
     * @return the HeaderField
     */
    public func getEntry(ind: Int64): HeaderField {
        let index = ind - 62
        if (index < 0 || index > length() || this.length() == 0) {
             throw IndexOutOfBoundsException()
        }
        let i: Int64 = this.head - 1 - index
        if (i < 0 && dynamicArray[i + dynamicArray.size][0]) {
            return dynamicArray[i + dynamicArray.size][1].getOrThrow()
        } else if (i >=0 && dynamicArray[i][0]){
            return dynamicArray[i][1].getOrThrow()
        }
        throw NoneValueException()
    }

    /**
     * Get header func.
     *
     * @return the func
     */
    public func getHeader(ind: Int64): Option<HeaderField> {
        let index = ind - 62
        if (index < 0 || index > length() || this.length() == 0) {
            throw IndexOutOfBoundsException("index ${index} out of bounds for length ${this.length()}")
        }
        let i: Int64 = index + this.tail
        if (i < 0) {
            return dynamicArray[i + dynamicArray.size][1]
        } else {
            return dynamicArray[i][1]
        }
    }

    public  func dynamicArrToString() : String {
        var str = ""
        for (item in dynamicArray) {
            match (item[1]) {
                case Some(v) =>
                    str += ", ${item[0]}: ${v}"
                case None =>
                    str += ", ${item[0]}: none"
            }
        }
        return str
    }

    /**
     * Remove func.
     *
     * @return the Option<HeaderField>
     */
    public func remove(): Option<HeaderField>{
        let (isValue, removed): (Bool, Option<HeaderField>) = this.dynamicArray[this.tail];
        if (!isValue) {
            return None
        }

        this.mySize = this.mySize - removed.getOrThrow().size()
        this.dynamicArray[this.tail] = NULL
        this.tail++
        if (this.tail == this.dynamicArray.size) {
            this.tail = 0
        }
        return removed
    }

    /**
     * Clear func.
     *
     * @return the Unit
     */
    public func clear(): Unit {
        while (this.tail != this.head) {
            this.dynamicArray[this.tail] = NULL
            this.tail++
            if (this.tail == this.dynamicArray.size) {
                this.tail = 0
            }
        }
        this.head = 0
        this.tail = 0
        this.mySize = 0
    }

    /**
     * Set capacity func.
     *
     * @return the Bool
     */
    /* size <= 0xFFFF_FFFF */
    public func setCapacity(s: UInt32): Bool {
        let newSize: Int64 = Int64(s)
        if (newSize == this.myCapacity) {
            return false
        }
        this.myCapacity = newSize
        if (newSize == 0) {
            this.clear()
            return false
        } else {
            while (this.mySize > newSize) {
                this.remove()
            }
        }
        /* set size*/
        var maxEntries: Int64 = newSize / CONST_32_I64
        if ((newSize - CONST_32_I64 * maxEntries) != 0) {
            maxEntries++
        }
        if (this.dynamicArray.size == maxEntries) {
            return false
        }
        let newFields: Array<(Bool, Option<HeaderField>)> = Array<(Bool, Option<HeaderField>)>(maxEntries, item: NULL)
        let len: Int64 = this.length()
        var cur: Int64 = this.tail
        for (i in 0..len) {
            newFields[i] = this.dynamicArray[cur]
            cur++
            if (cur == this.dynamicArray.size) {
                cur = 0  // ring array set to 0 index
            }
        }
        this.tail = 0
        this.head = this.tail + len
        this.dynamicArray = newFields
        return true
    }

    /**
     * Search func.
     *
     * @return the Int64*Int64*Bool
     */
     func search(f: HeaderField) : (Int64, Int64, Bool) {
        var index = 0
        var value: Int64 = -1
        var key: Int64 = -1
        var i: Int64 = this.head - 1
        var bo: Bool = false

        while (i >= this.tail) {
            if (dynamicArray[i][0]) {
                match (dynamicArray[i][1]) {
                    case Some(v) =>
                        if (v.name == f.name) {
                            key = index
                            if (v.value == f.value) {
                                value = index
                                dynamicArray[i] = (true, HeaderField(f.name, f.value, f.sensitive))
                                bo = f.sensitive
                            }
                        }
                    case None => ()
                }
            }
            i--
            index++
        }

        if (key < 0) {
            return (key, value, bo)
        } else if (value < 0) {
            return (key + 62, value, bo)
        }
        return (value + 62, value + 62, bo)
    }
}

extend DynamicTables <: ToString {
    public func toString(): String {
        var str = ""
        var index = 62
        for (i in head..= this.tail:-1 where this.dynamicArray[i][0]) {
            str += "${index}=[${this.dynamicArray[i][1].toString()}]\r\n"
            index ++
        }
        return str
    }
}
