/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declares the Decoder class.
 */

package okhttp


/**
 * The enum Index type.
 */
public enum IndexType {
    | INCREMENTAL | NONE | NEVER

    /**
     * Indexed func.
     *
     * @return Bool
     */
    public func indexed(): Bool {
        return match (this) {
            case NONE => false
            case NEVER => false
            case INCREMENTAL => true
        }
    }

    /**
     * Sensitive func.
     *
     * @return Bool
     */
    public func sensitive(): Bool {
        return match (this) {
            case NONE => false
            case NEVER => true
            case INCREMENTAL => false
        }
    }
}

/**
 * The type Decoder.
 * Prefix 0000 and 0001, the difference is:
 * There is no need to update the representation. This field will not be updated to the dynamic table during this sending process; If there are multiple forwarding, the forwarding is not required
 * Update is absolutely not allowed. If the request is forwarded to the target multiple times, all the forwarding intermediaries must adopt the same processing scheme for this field
 * @author liyanqing14
 * @since 0.29.3
 */
class Decoder {
    private var dynTab: DynamicTables
    private var maxDynamicTableSizeChangeRequired: Bool = false
    private var saveBuf: ArrayList<UInt8>
    // 0b1000_0000 128 128
    private static let INDEXD: (UInt8, UInt8) = (0b1000_0000, 0b0000_0000)
    // 0b0100_0000 192 64
    private static let LITERAL_WITH_INDEXING: (UInt8, UInt8) = (0b1100_0000, 0b0100_0000)
    // 0b0010_0000 224 32
    private static let SIZE_UPDATE: (UInt8, UInt8) = (0b1110_0000, 0b0010_0000)
    // 0b0001_0000 240 16
    private static let LITERAL_NEVER_INDEXED: (UInt8, UInt8) = (0b1111_0000, 0b0001_0000)
    // 0b0000_0000 240 0
    private static let LITERAL: (UInt8, UInt8) = (0b1111_0000, 0b0000_0000)
    init(dynTab: DynamicTables) {
        this.dynTab = dynTab
        this.saveBuf = ArrayList<UInt8>()
    }

    /**
     * Instantiates a new New decode.
     *
     * @return Type of Decoder
     * @since 0.29.3
     */
    public static func newDecode(): Decoder {
        return newDecode(4096)
    }

    /**
     * Instantiates a new New decode.
     *
     * @param capa of Int64
     *
     * @return Type of Decoder
     * @since 0.29.3
     */
    public static func newDecode(capa: Int64): Decoder {
        return Decoder(DynamicTables(capa))
    }

    /**
     * Decode func.
     *       0   1   2  ... n-3 n-2 n-1  n
     *     +---+---+---+---+---+---+---+---+
     *     | b | b | b |...| b | b | b | b |
     *     +---+---+---+---+---+---+---+---+
     *       ^ ->
     *       i = i + 1
     * @return the func
     */
    public func decode(src: Array<UInt8>): Array<HeaderField> {
        let headerBuf = ArrayList<HeaderField>()
        var i: Int64 = 0
        while (i < src.size && i != -1) {
            /*
             *       0   1   2   3   4   5   6   7
             *     +---+---+---+---+---+---+---+---+
             *     | 1 |       Max size (7+)       |
             *     +---+---------------------------+
             */
            if ((src[i] & INDEXD[0]) != INDEXD[1]) {
                i = parseFieldIndexed(src, i, headerBuf)
            }
            /*
             *       0   1   2   3   4   5   6   7
             *     +---+---+---+---+---+---+---+---+
             *     | 0 | 1 |   Max size (6+)       |
             *     +---+---------------------------+
             */
            else if ( (src[i] & LITERAL_WITH_INDEXING[0]) == LITERAL_WITH_INDEXING[1]) {
                i = parseFieldLiteral(src, i, INDEXD_TRUE, INCREMENTAL, headerBuf)
            }
            /*
             *       0   1   2   3   4   5   6   7
             *     +---+---+---+---+---+---+---+---+
             *     | 0 | 0 | 1 |   size update     |
             *     +---+---------------------------+
             */
            else if ( (src[i] & SIZE_UPDATE[0] ) == SIZE_UPDATE[1]) {
                i = parseUpdateDynamicTableSize(src, i)
            }
            /*
             *       0   1   2   3   4   5   6   7
             *     +---+---+---+---+---+---+---+---+
             *     | 0 | 0 | 0 | 1 |  size (4+)    |
             *     +---+---------------------------+
             */
            else if ((src[i] & LITERAL_NEVER_INDEXED[0]) == LITERAL_NEVER_INDEXED[1]) {
                i = parseFieldLiteral(src, i, INDEXD_NEVER, NEVER, headerBuf)
            }
            /*
             *       0   1   2   3   4   5   6   7
             *     +---+---+---+---+---+---+---+---+
             *     | 0 | 0 | 0 | 0 |  size (4+)    |
             *     +---+---------------------------+
             */
            else if ((src[i] & LITERAL[0]) == LITERAL[1]) {
                i = parseFieldLiteral(src, i, INDEXD_NONE, NONE, headerBuf)
            }
        }
        return headerBuf.toArray()
    }

    /**
     *   Maximum Dynamic Table Size Change.
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 0 | 0 | 1 |   Max size (5+)   |
     *     +---+---------------------------+
     */
    public func parseUpdateDynamicTableSize(src: Array<UInt8>, index: Int64): Int64 {
        if (index >= src.size) {
            return -1
        }
        let (idx, newIdx) = readVarInt(src, index, CHANGE_TABLE)
        dynTab.setCapacity(UInt32(idx))
        return newIdx
    }


    public func updateMaxSize(size: UInt32): Unit {
        let len: UInt32 = size - UInt32(HeaderStaticTable.capacity)
        if (!maxDynamicTableSizeChangeRequired) {
            let isSetCap: Bool = dynTab.setCapacity(len)
            if (isSetCap) {
                maxDynamicTableSizeChangeRequired = true
            }
        }
    }

    /**
     * Parse field literal func.
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 0 | 1 |   Max size (6+)       |
     *     +---+---------------------------+
     *
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 0 | 0 | 0 | 0 |  size (4+)    |
     *     +---+---------------------------+
     *
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 0 | 0 | 0 | 1 |  size (4+)    |
     *     +---+---------------------------+
     * @return the func
     */
    public func parseFieldLiteral(src: Array<UInt8>, index: Int64, N: Int64, that: IndexType, buf: ArrayList<HeaderField>): Int64 {
        if (index >= src.size) {
            return -1
        }
        let (idx, newIdx) = readVarInt(src, index, N)
        var newIndex = newIdx
        var name: String = ""
        if (idx > 0) {
            let ihf: HeaderField = getHeader(idx)
            name = ihf.name
            newIndex = newIndex
        } else {
            let (strArr, len) = readString(src, newIndex)
            newIndex = len
            name = String.fromUtf8(strArr)
        }
        let (valArr, len) = readString(src, newIndex)
        var value: String = String.fromUtf8(valArr)
        newIndex = len
        let header: HeaderField = HeaderField(name, value, that.sensitive())
        if (that.indexed()) {
            dynTab.add(header)
        }
        buf.append(header)
        return newIndex
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
     *     |           ASCII               |
     *     +-------------------------------+
     */
    public func readString(src: Array<UInt8>, i: Int64): (Array<UInt8>, Int64) {
        if (i >= src.size) {
            return (Array<UInt8>(), -1)
        }
        var index = i
        let (idx, len) = readVarInt(src, index, INDEXD_SUCCESS)
        index++
        // ascii
        var length = len + idx
        let strArr = if ((src[i] & CONST_128_U8)== 0) {
            src[index..length]
        } else {  // HUFFMAN
            let arr = ByteArrayList()
            let ctx = HuffDecodeContext(HUFF_ACCEPTED)
            huff_decode(ctx , arr, src[index..length], true)
            arr.toArray()
        }
        return (strArr, length)
    }

    /**
     *       0   1   2   3   4   5   6   7
     *     +---+---+---+---+---+---+---+---+
     *     | 1 |       Max size (7+)       |
     *     +---+---------------------------+
     */
    public func parseFieldIndexed(src: Array<UInt8>, index: Int64, buf: ArrayList<HeaderField>): Int64 {
        if (src.size <= index) {
            return -1
        }
        let (idx, newIndex) = readVarInt(src, index, INDEXD_SUCCESS)
        buf.append(getHeader(idx))
        return newIndex
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
    @overflowWrapping
    public func readVarInt(src: Array<UInt8>, index: Int64, N: Int64): (Int64, Int64) {
        var indexVar: Int64 = index
        if (src.size <= indexVar || N <= 0 || N > BYTE_SIZE) {
            throw IndexOutOfBoundsException()
        }
        var srci: Int64 = Int64(src[indexVar])
        indexVar++
        if (N < BYTE_SIZE) {
            srci &= (1 << N) - 1
        }
        if (srci < (1 << N) - 1) {
            return (srci, indexVar)
        }
        var bit = 0
        for (i in indexVar..src.size) {
            indexVar++
            srci += Int64(src[i] & CONST_127_U8) << bit
            bit += VAILD_BIT
            if (bit >= CONST_63_I64) {
                throw IndexOutOfBoundsException()
            }
            if ((src[i] & CONST_128_U8) == 0) {
                break
            }
        }
        return (srci, indexVar)
    }

    /**
     * Get header func.
     *
     * @return HeaderField
     */
    public func getHeader(index: Int64): HeaderField {
        if (index <= 0) {
            throw IndexOutOfBoundsException()
        }
        if (index <= STATIC_TABLE_SIZE) {
            return HeaderStaticTable.getIndex(index)
        }
        return dynTab.getEntry(index)
    }
}


class ByteArrayList <: Collection<UInt8>{
    protected var buf: ArrayList<UInt8> =ArrayList<UInt8>()
    protected var offset: Int64 = 0
    protected var isReadOnly: Bool = false

    protected var mycapacity = 16

    protected var bigEndian: Bool = false

    init () {
        this.bigEndian = true
        this.buf = ArrayList<UInt8>()
    }

    public func add(b: UInt32) {
        if (bigEndian) {
            add(UInt16(b >> 16))
            add(UInt16(b & 0xffff))
        } else {
            add(UInt16(b & 0xffff))
            add(UInt16(b >> 16))
        }
    }

    public func add(b: UInt16) {
        if (bigEndian) {
            add(UInt8(b >> 8))
            add(UInt8(b & 0xff))
        } else {
            add(UInt8(b & 0xff))
            add(UInt8(b >> 8))
        }
    }

    public func add(b: UInt8) {
        buf.append(b)
        if (buf.size == mycapacity) {
            mycapacity = mycapacity << 1
        }
    }

    // huffman
    public func getCurAvail(): Int64 {
        return mycapacity - buf.size
    }

    public func isEmpty(): Bool {
        return buf.size == 0
    }

    public func iterator(): Iterator<UInt8> {
        return buf.iterator()
    }

    public prop let size: Int64 {
        get() {
            return buf.size
        }
    }
}

