/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the StatusLine class.
 */
package okhttp

/**
 * The class is StatusLine
 * @author guo_tingtingtekla,luoyukai4
 * @since 0.29.3
 */
public class StatusLine <: ToString {
    /** var member HTTP_TEMP_REDIRECT type is Int64 */
    public static let HTTP_TEMP_REDIRECT: Int64 = 307
    /** var member HTTP_PERM_REDIRECT type is Int64 */
    public static let HTTP_PERM_REDIRECT: Int64 = 308
    /** var member HTTP_MULT_CHOICE type is Int64 */
    public static let HTTP_MULT_CHOICE: Int64 = 300
    /** var member HTTP_MOVED_PERM type is Int64 */
    public static let HTTP_MOVED_PERM: Int64 = 301
    /** var member HTTP_MOVED_TEMP type is Int64 */
    public static let HTTP_MOVED_TEMP: Int64 = 302
    /** var member HTTP_SEE_OTHER type is Int64 */
    public static let HTTP_SEE_OTHER: Int64 = 303
    public let protocol: Protocol
    public let code: Int64
    public let message: String

    public init (protocol: Protocol, code: Int64, message: String) {
        this.protocol = protocol
        this.code = code
        this.message = message
    }

    public static func parse(statusLine: String): StatusLine {
        let codeStart: Int64 = 9
        var protocol = Protocol.HTTP_1_0

        if (statusLine.startsWith("HTTP/1.")) {
            if (statusLine.size < 9 || statusLine.charAt(8) != ' ') {
                throw ProtocolException("Unexpected status line: ${statusLine}")
            }
            let httpMinorVersion = statusLine.charAt(7)
            if (httpMinorVersion == '0') {
                protocol = Protocol.HTTP_1_0
            } else if (httpMinorVersion == '1') {
                protocol = Protocol.HTTP_1_1
            } else {
                throw ProtocolException("Unexpected status line: ${statusLine}")
            }
        } else {
            throw ProtocolException("Unexpected status line: ${statusLine}")
        }

        if (statusLine.size < codeStart + 3) {
           throw ProtocolException("Unexpected status line: ${statusLine}")
        }

        let statusCode = match (Int64.tryParse(statusLine.substring(9, 3))) {
            case Some (x) => x
            case None => throw ProtocolException("Unexpected status line: ${statusLine}")
        }

        var message: String = ""

        if (statusLine.size > codeStart + 3) {
          if (statusLine.charAt(codeStart + 3) != ' ') {
            throw ProtocolException("Unexpected status line: ${statusLine}")
          }
          message = statusLine.substring(codeStart + 4)
        }

        return StatusLine(protocol, statusCode , message)
    }

    public func toString(): String {
        let sb: StringBuilder = StringBuilder()
        sb.append("${protocol}")
        sb.append(' ').append(code)
        if (message != "") {
            sb.append(' ').append(message)
        }
        return "${sb}"
    }
}

