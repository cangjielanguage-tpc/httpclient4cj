/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights reserved.
 * Description:
 */

/**
 * @file The file declars the ByteBuffer class.
 */

package okhttp


let HUFF_SYM: UInt16 = 0b1000_0000_0000_0000
let HUFF_ACCEPTED: UInt16 = 0b100_0000_0000_0000

/**
 * Huff encode count func.
 *
 * @return the Int64
 */
func huff_encode_count(list: ArrayList<UInt8>): Int64 {
    var bits: Int64 = 0

    for (i in 0..list.size) {
        bits += Int64(HUFF_SYM_TABLE[Int64(list[i])][0])
    }

    return (bits + VAILD_BIT) / BYTE_SIZE
}

/**
 * The type Huff sym.
 */
struct huff_sym {
    public var nbits: UInt32
    public var code: UInt32

    public huff_sym(public let tuple: (UInt32, UInt32)) {
        code = tuple[1]
        nbits = tuple[0]
    }
}

/**
 * Huff encode func.
 *
 * @return the func
 */
@overflowWrapping
func huff_encode(bufs: ByteArrayList, src: Array<UInt8>) {
    let bits_32 = 32
    let bits_56 = 56
    let bits_4 = 4
    let bits_8 = 8
    var sym: huff_sym = huff_sym((0,0))
    var bits = 0
    var code: UInt64 = 0
    var avail: Int64 = bufs.getCurAvail()
    for (i in src) {
        sym = huff_sym(HUFF_SYM_TABLE[Int64(i)])
        code |= UInt64(UInt64(sym.code) << (bits_32 - bits))
        bits += Int64(sym.nbits)

        if (bits < bits_32) {
            continue
        }

        if (avail >= bits_4) {
            bufs.add(UInt32(code >> bits_32))
            avail -= bits_4
            code <<= UInt64(bits_32)
            bits -= bits_32
            continue
        }

        while (bits >= bits_8) {
            bufs.add(UInt8(code >> bits_56))
            code <<= UInt64(bits_8)
            bits -= bits_8
        }
        avail = bufs.getCurAvail()
    }

    while (bits >= bits_8) {
        bufs.add(UInt8(code >> bits_56))
        code <<= UInt64(bits_8)
        bits -= bits_8
    }

    if (bits != 0) {
        bufs.add(UInt8(code >> bits_56) | UInt8(((1 << (bits_8 - bits)) - 1)))
    }
}

/**
 * The type Huff decode context.
 */
/* fstate is the current huffman decoding state. */
class HuffDecodeContext {
    public var fstate: UInt16
    public HuffDecodeContext(f: UInt16) {
        fstate = f
    }
}


/**
 * The type Huff decode.
 */
struct HuffDecode {
    public var fstate: UInt16
    public var sym: UInt8

    /**
     * Instantiates a new Huff decode.
     *
     * @param param the param
     */
    public HuffDecode(public let param: (UInt16, UInt8)) {
        sym = param[1]
        fstate = param[0]
    }
}

func huff_decode(ctx: HuffDecodeContext, buf: ByteArrayList, src: Array<UInt8>, fin: Bool) {
    var node: HuffDecode = HuffDecode((ctx.fstate, 0))
    let bits_size: Int64 = 0x1ff

    for (s in src) {
        node = HuffDecode(HUFF_DECODE_TABLE[Int64(node.fstate) & bits_size][Int64(s >> 4)])
        if ((node.fstate & HUFF_SYM) != 0) {
            buf.add(node.sym)
        }
        node = HuffDecode(HUFF_DECODE_TABLE[Int64(node.fstate) & bits_size][Int64(s & 0xf)])
        if ((node.fstate & HUFF_SYM) != 0) {
            buf.add(node.sym)
        }
    }

    ctx.fstate = node.fstate
}