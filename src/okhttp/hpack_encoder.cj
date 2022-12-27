/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the Encoder class.
 */
package okhttp


/**
 * The type Encoder.
 * @author liyanqing14
 * @since 0.29.3
 */
class Encoder <: ToString {
    var dynTab: DynamicTables
    var minSize: Int64
    var myBuffer: ArrayList<UInt8>
    private var tableSizeUpdate: Bool

    /* init empty encoder */
    protected init(dynTab: DynamicTables, minSize: Int64) {
        this.minSize = minSize
        this.dynTab = dynTab
        this.tableSizeUpdate = false
        this.myBuffer = ArrayList<UInt8>()
    }

    init(dynTab: DynamicTables) {
        this(dynTab, dynTab.capacity())
    }

    /**
     * New encoder func.
     *
     * @return the Encoder
     */
    /* init encoder */
    static func newEncoder(): Encoder{
        return Encoder(DynamicTables(4096), 4096)
    }

    /**
     * New encoder func.
     *
     * @return the Encoder
     */
    static func newEncoder(maxSize: Int64): Encoder{
        return Encoder(DynamicTables(maxSize), maxSize)
    }

    /**
     * Encode func.
     *
     * @return the Array<UInt8>
     */
    func encode(headers: Collection<HeaderField>): Array<UInt8> {
        if (myBuffer.size != 0) {
            myBuffer.clear()
        }
        if (tableSizeUpdate) {
            updateMaxSize(UInt32(minSize))
            addTableSize(UInt32(minSize))
            tableSizeUpdate = true
        }
        for (header in headers) {
            var (keyIndex, keyValueIndex) = searchFull(header)
            if (keyValueIndex > 0) {
                addIndexed(UInt64(keyValueIndex))
            } else {
                let canIndex = canIndex(header)
                if (canIndex) {
                    dynTab.add(header)
                }
                if (keyIndex <= 0) {
                    addNewField(header, canIndex)
                } else {
                    addIndexedName(header, keyIndex, canIndex)
                }
            }
        }
        return myBuffer.toArray()
    }

    /**
     * Update max size func.
     *
     * @return the Unit
     */
    func updateMaxSize(size: UInt32): Unit {
        let len: UInt32 = size - UInt32(HeaderStaticTable.capacity)
        if (!tableSizeUpdate) {
            if (dynTab.setCapacity(len)) {
                tableSizeUpdate = true
            }
        }
    }

    public func toString(): String {
        return dynTab.toString()
    }

    /**
     * Can index func.
     *
     * @return the func
     */
    func canIndex(f: HeaderField): Bool {
        let boo = f.size() < dynTab.capacity()
        return !f.sensitive && boo
    }

    func searchFull(f: HeaderField): (Int64, Int64) {
        var (keyIndex, kvIndex) = HeaderStaticTable.searchFull(f)
        var (dykeyIndex, dykvIndex, dyBo) = dynTab.search(f)

        match {
            case kvIndex > 0 && keyIndex > 0 => return (keyIndex, kvIndex)
            case dykeyIndex > 0 && keyIndex > 0 => return (dykeyIndex, dykvIndex)
            case dykeyIndex < 0 && keyIndex > 0 => return (keyIndex, kvIndex)
            case dykvIndex > 0 && keyIndex < 0 => return (dykeyIndex, dykvIndex)
            case dykeyIndex > 0 && keyIndex < 0 => return (dykeyIndex, dykvIndex)
            case _ => return (keyIndex, kvIndex)
        }
    }

    /**
     * Add indexed func.
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 1 |       Max size (7+)       |
     *     +---+---------------------------+
     * @return the func
     */
    func addIndexed(i: UInt64) {
        let first: Int64 = myBuffer.size
        addByteInt(VAILD_BIT, i)
        myBuffer[first] |= CONST_128_U8
    }

    /**
     * Literal Header Field without Indexing – New Name.
     *     0   1   2   3   4   5   6   7
     *   +---+---+---+---+---+---+---+---+
     *   | 0 | 0 | 0 | 0 |       0       |
     *   +---+---+-----------------------+
     *   | H |     Name Length (7+)      |
     *   +---+---------------------------+
     *   |  Name String (Length octets)  |
     *   +---+---------------------------+
     *   | H |     Value Length (7+)     |
     *   +---+---------------------------+
     *   | Value String (Length octets)  |
     *   +-------------------------------+
     *
     * Literal Header Field Never Indexed – New Name
     *    0   1   2   3   4   5   6   7
     *  +---+---+---+---+---+---+---+---+
     *  | 0 | 0 | 0 | 1 |       0       |
     *  +---+---+-----------------------+
     *  | H |     Name Length (7+)      |
     *  +---+---------------------------+
     *  |  Name String (Length octets)  |
     *  +---+---------------------------+
     *  | H |     Value Length (7+)     |
     *  +---+---------------------------+
     *  | Value String (Length octets)  |
     *  +-------------------------------+
     *
     */
    func addNewField(f: HeaderField, indexing: Bool) {
        myBuffer.append(encodeTypeByte(indexing, f.sensitive))
        addHPackString(f.name)
        addHPackString(f.value)
    }

    /**
     *   Maximum Dynamic Table Size Change.
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 0 | 0 | 1 |   Max size (5+)   |
     *     +---+---------------------------+
     */
    func addTableSize(v: UInt32) {
        let len: Int64 = myBuffer.size
        addByteInt(CHANGE_TABLE, UInt64(v))
        myBuffer[len] |= CONST_32_U8
    }

    /**
     * Add indexed name func.
     *
     * @return the func
     */
    func addIndexedName(field: HeaderField, index: Int64, canIndex: Bool) {
        let first: Int64 = myBuffer.size
        let N: Int64 = if (canIndex) {
            INDEXD_TRUE
        } else {
            INDEXD_NONE
        }
        addByteInt(N, UInt64(index))
        myBuffer[first] |= encodeTypeByte(canIndex, field.sensitive)
        addHPackString(field.value)
    }

    /**
     *    value is not in the table.
     *       0   1   2   3   4   5   6   7
     *     +---+---+-----------------------+
     *     | H |     Value Length (7+)     |
     *     +---+---------------------------+
     *     | Value String (Length octets)  |
     *     +-------------------------------+
     *
     *    Huffman encoding is greater than the length of the string and uses ascII directly
     *       0   1   2   3   4   5   6   7
     *     +---+---+-----------------------+
     *     | 0 |     Value Length (7+)     |
     *     +---+---------------------------+
     *     | ascII                         |
     *     +-------------------------------+
     *     | ........                      |
     *     +-------------------------------+
     */
    func addHPackString(str: String) {
        let len: Int64 = huff_encode_count(myBuffer.clone())
        let strLen: Int64 = str.utf8View.size
        if (len < strLen) {
            let first: Int64 = myBuffer.size
            let arr = ByteArrayList()
            huff_encode(arr, str.toUtf8Array())
            let huffArr = arr.toArray()
            myBuffer.append(UInt8(huffArr.size | CONST_128_I64))
            myBuffer.appendAll(arr.toArray())
        } else {
            let arr = str.toUtf8Array()
            myBuffer.append(UInt8(arr.size))
            myBuffer.appendAll(str.toUtf8Array())
        }
    }

    /**
     * An integer is used to indicate a name index, header field index, or string length.
     * Integers indicate that you can start anywhere within eight bytes. To optimize processing,
     * integer representations always end at the end of the octet.
     *      0   1   2   3   4   5   6   7
     *    +---+---+---+---+---+---+---+---+
     *    | ? | ? | ? | 1   1   1   1   1 |
     *    +---+---+---+-------------------+
     *    | 1 |    Value-(2^N-1) LSB      |
     *    +---+---------------------------+
     *                   ...
     *    +---+---------------------------+
     *    | 0 |    Value-(2^N-1) MSB      |
     *    +---+---------------------------+
     */
    func addByteInt(N: Int64, v: UInt64) {
        checkPrefix(N)
        let line: UInt8 = UInt8((1 << N) - 1)
        if (v < UInt64(line)) {
            myBuffer.append(UInt8(v))
            return
        }
        var n: UInt64 = v - UInt64(line)
        myBuffer.append(line)
        while (n >= UInt64(CONST_128_I64)) {
            myBuffer.append(UInt8((n & UInt64(CONST_127_I64)) | UInt64(CONST_128_I64)))
            n >>= UInt64(VAILD_BIT)
        }
        myBuffer.append(UInt8(n))
    }

    /**
     * Check prefix func.
     *
     * @return the func
     */
    func checkPrefix(N: Int64) {
        if (N <= 0 || N > Int64(BYTE_SIZE)) {
            throw IllegalArgumentException("N in [1..8], but N= ${N}")
        }
    }

    /**
     * A text header field that is not indexed
     *   0   1   2   3   4   5   6   7
     *  +---+---+---+---+---+---+---+---+
     *  | 0 | 0 | 0 | 1 |  Index (4+)   |
     *  +---+---+-----------------------+
     *
     * A text header field with an incremental index
     *   0   1   2   3   4   5   6   7
     *  +---+---+---+---+---+---+---+---+
     *  | 0 | 1 |      Index (6+)       |
     *  +---+---+-----------------------+
     *
     * A text header field without an index.
     *   0   1   2   3   4   5   6   7
     *  +---+---+---+---+---+---+---+---+
     *  | 0 | 0 | 0 | 0 |       0       |
     *  +---+---+-----------------------+
     */
    func encodeTypeByte(indexing: Bool, sensitive: Bool) : UInt8{
        if (sensitive) {
            return CONST_16_U8
        }
        if (indexing) {
            return CONST_64_U8
        }
        return 0
    }
}