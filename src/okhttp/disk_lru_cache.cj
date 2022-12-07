/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * The file declares the CallServerInterceptor class.
 */
package okhttp


public class DiskLruCache {
    let fileSystem: FileSystem
    let directory: File
    var appVersion: Int64
    var valueCount: Int64
    private var maxSize: Int64
    private var size: Int64 = 0
    let lock: Monitor = Monitor()
    var initialized: Bool = false
    var closed: Bool = false
    //private let journalFileBackup: File
   //private let journalFile: File
   //private let journalFileTmp: File
    static let JOURNAL_FILE: String = "journal"
    static let JOURNAL_FILE_TEMP: String = "journal.tmp"
    static let JOURNAL_FILE_BACKUP: String = "journal.bkp"
    static let VERSION_1: String = "1"
    static let MAGIC: String = "libcore.io.DiskLruCache"
    static let CLEAN: String = "CLEAN"
    static let DIRTY: String = "DIRTY"
    static let REMOVE: String = "REMOVE"
    static let READ: String = "READ"
    static let LEGAL_KEY_PATTERN: String = "[a-z0-9_-]{1,120}"
    let lruEntries: HashMap<String, Entry> = HashMap<String, Entry>()
    var journalWriter: RealBufferSink
    var redundantOpCount: Int64 = 0
    var hasJournalErrors: Bool = false
    var mostRecentTrimFailed: Bool = false
    var mostRecentRebuildFailed: Bool = false


    init(fileSystem: FileSystem, directory: Directory, appVersion: Int64, valueCount: Int64, maxSize: Int64) {
        this.fileSystem = fileSystem
        this.directory = directory
        this.appVersion = appVersion
        this.valueCount = valueCount
        this.maxSize = maxSize
        //this.journalFile = initCreate(directory, JOURNAL_FILE)
        //this.journalFileTmp = initCreate(directory, JOURNAL_FILE_TEMP)
        //this.journalFileBackup =  initCreate(directory, JOURNAL_FILE_BACKUP)
    }

    func initCreate(directory: Directory, fileName: String): Unit {
        let name = directory.info.ToString() + fileName
        if (!File.exists(name)) {
            return directory.createFile(name)
        }
        return File(name)
    }

    public static func create(fileSystem: FileSystem, directory: Directory,
        appVersion: Int64, valueCount: Int64, maxSize: Int64): DiskLruCache {

        if (maxSize <= 0) {
            throw IllegalArgumentException("maxSize <= 0");
        }

        if (valueCount <= 0) {
            throw IllegalArgumentException("valueCount <= 0");
        }

        return DiskLruCache(fileSystem, directory, appVersion, valueCount, maxSize)
    }

    public func remove(key: String) {


    }

    public func get(key: String): Option<Snapshot> {
        synchronized(lock) {
            initialize()
            checkNotClosed()
            validateKey(key)
            match (lruEntries.get(key)) {
                case None => return None
                case Some(v) =>
                    if (!entry.readable) {
                        return None
                    }
            }

            match (entry.snapshot()) {
                case None => return None
                case Some(v) =>
                    redundantOpCount++
                    journalWriter.write(READ.toUtf8Array()).write(" ".toUtf8Array()).
                        write(key.toUtf8Array()).write("\n".toUtf8Array())
                    if (journalRebuildRequired()) {
                        spawn {
                            cleanUp()
                        }
                    }
                    return v
            }
        }
    }

    func cleanUp(): Unit {
        synchronized(lock) {
            if (!initialized | closed) {
                return // Nothing to do
            }

            try {
                trimToSize()
            } catch (e : Exception) {
                mostRecentTrimFailed = true
            }

            try {
                if (journalRebuildRequired()) {
                    rebuildJournal()
                    redundantOpCount = 0
                }
            } catch (IOException e) {
                mostRecentRebuildFailed = true

                //TODO blackhole
                //journalWriter = Okio.buffer(Okio.blackhole())
            }
        }
    }

    func journalRebuildRequired() {
        let redundantOpCompactThreshold = 2000
        return redundantOpCount >= redundantOpCompactThreshold
            && redundantOpCount >= lruEntries.size
    }

    func removeEntry(entry: Entry) {
        match (entry.currentEditor) {
            case Some(ce) =>
                ce.detach()
            case None => ()
        }

        for (i in 0..valueCount) {
            fileSystem.delete(entry.cleanFiles[i])
            size -= entry.lengths[i]
            entry.lengths[i] = 0
        }
        redundantOpCount++
        journalWriter.write(REMOVE.toUtf8Array()).write(" ".toUtf8Array()).
                        write(key.toUtf8Array()).write("\n".toUtf8Array())
        lruEntries.remove(entry.key)
        if (journalRebuildRequired()) {
              spawn {
                  cleanUp()
              }
        }
    }

    private func validateKey(key: String): Unit {
         let matcher: Matcher = Regex(LEGAL_KEY_PATTERN).matcher(string)
         match (matcher.find()) {
             case None =>
                 throw IllegalArgumentException("keys must match regex [a-z0-9_-]{1,120}: ${key}")
             case Some(data) =>
                 ()
         }
    }

    private func checkNotClosed(): Unit {
        synchronized(lock) {
            if (isClosed()) {
                throw IllegalStateException("cache is closed")
            }
        }
    }

    public func isClosed(): Bool {
        synchronized(lock) {
            return closed
        }
    }
    func trimToSize() {
        while (size > maxSize) {
            let toEvict: Entry = lruEntries.values().iterator().next().getOrThrow()
            removeEntry(toEvict)
        }
        mostRecentTrimFailed = false
    }

    public func initialize(): Unit {
        synchronized(lock) {
            if (initialized) {
                return // Already initialized.
            }

             // If a bkp file exists, use it instead.
            if (fileSystem.exists(journalFileBackup)) {
                if (fileSystem.exists(journalFile)) {
                    fileSystem.delete(journalFileBackup)
                } else {
                    fileSystem.rename(journalFileBackup, journalFile)
                }
            }

            // Prefer to pick up where we left off.
            if (fileSystem.exists(journalFile)) {
                try {
                    readJournal()
                    processJournal()
                    initialized = true
                    return
                } catch (e: Exception) {

                }

                try {
                    delete();
                } finally {
                    closed = false
                }

                rebuildJournal()

                initialized = true
            }
        }
    }

    private func processJournal(): Unit {
        fileSystem.delete(JOURNAL_FILE_TMP)
        let arr = ArrayList<String>()
        for (key in lruEntries.keys()) {
            let entry = lruEntries[key]
            match (entry.currentEditor) {
                case None =>
                    for (i in 0..valueCount) {
                        size += entry.lengths[i]
                    }
                case Some(ce) =>
                    entry.currentEditor = None
                    for (i in 0..valueCount) {
                        fileSystem.delete(entry.cleanFiles[i])
                        fileSystem.delete(entry.dirtyFiles[i])
                    }
                    arr.append(key)
            }
        }
        lruEntries.removeAll(arr)
    }

    private func readJournal() {
        try (source = OkBuffer(fileSystem.source(File(JOURNAL_FILE)))) {
            let magic = source.readUtf8LineStrict()
            let version = source.readUtf8LineStrict()
            let valueCountString = source.readUtf8LineStrict()
            let blank = source.readUtf8LineStrict()

            if (!MAGIC.equals(magic)
                || !VERSION_1.equals(version)
                || !Int64.parse(valueCount).equals(valueCountString)
                || !"".equals(blank) {
                throw HttpException("unexpected journal header: [${magic},${version},${valueCountString},${blank})
            }

            let lineCount = 0

            while(true) {
                try {
                    readJournalLine(source.readUtf8LineStrict())
                    lineCount++
                } catch (endOfJournal: Exception) {
                    break
                }
            }

            redundantOpCount = lineCount - lruEntries.size()

            if (!source.exhausted()) {
                rebuildJournal()
            } else {
               journalWriter = newJournalWriter()
            }
        }

    }

    private func newJournalWriter(): RealBufferSink {
        return RealBufferSink(fileSystem.appendingSink(JOURNAL_FILE))
    }

    func rebuildJournal(): Unit {
        synchronized(lock) {
            match(journalWriter)) {
                case Some(jw) =>
                    jw.close()
                case None => ()
            }
            try (writer = RealBufferSink(fileSystem.sink(JOURNAL_FILE_TEMP))) {
                writer.write(MAGIC.toUtf8Array())
                writer.write("\n".toUtf8Array())
                writer.write(VERSION_1.toUtf8Array())
                writer.write("\n".toUtf8Array())
                writer.write("${valueCount}".toUtf8Array())
                writer.write('\n')
                for (v in lruEntries.values()) {
                    match (v.currentEditor) {
                        case Some(ce) =>
                            writer.write((DIRTY+ " ").toUtf8Array())
                            writer.write(entry.key.toUtf8Array())
                            writer.write("\n".toUtf8Array())
                        case None =>
                            writer.write((CLEAN+ " ").toUtf8Array())
                            writer.write(entry.key.toUtf8Array())
                            entry.writeLengths(writer)
                            writer.write("\n".toUtf8Array())
                    }
                }

            }
            if (fileSystem.exists(JOURNAL_FILE)) {
                fileSystem.rename(JOURNAL_FILE, JOURNAL_FILE_BACKUP)
            }
            fileSystem.rename(JOURNAL_FILE_TMP, JOURNAL_FILE)
            fileSystem.delete(JOURNAL_FILE_BACKUP)

            journalWriter = newJournalWriter()
            hasJournalErrors = false
            mostRecentRebuildFailed = false
        }
    }

    private func readJournalLine(line: String) {
        let firstSpace = line.indexOf(' ').getOrThrow({() => HttpException("unexpected journal line: ${line}")})
        let keyBegin = firstSpace + 1

        let key: String
        let secondSpace = match (line.indexOf(' ', keyBegin)) {
            case Some(index) =>
                 key = line[keyBegin, index]
                 return index
            case None =>
                 key = line.substring(keyBegin, line.size)
                 if (firstSpace == REMOVE.length() && line.startsWith(REMOVE)) {
                    lruEntries.remove(key)

                }
                return -1
        }

        var entry: Entry = match (lruEntries.get(key)) {
            case Some(e) =>
                return e
            case None =>
                let e = Entry(key)
                lruEntries.put(key, e)
                return e
        }

        if (secondSpace != -1 && firstSpace == CLEAN.length() && line.startsWith(CLEAN)) {
            let parts: Array<String> = line.substring(secondSpace + 1).split(" ")
            entry.readable = true
            entry.currentEditor = None
            entry.setLengths(parts)
        } else if (secondSpace == -1 && firstSpace == DIRTY.length() && line.startsWith(DIRTY)) {
            entry.currentEditor = Editor(entry)
        } else if (secondSpace == -1 && firstSpace == READ.length() && line.startsWith(READ)) {
            // This work was already done by calling lruEntries.get().
        } else {
            throw HttpException("unexpected journal line: ${line}")
        }
    }
}

public class Editor {
    let entry: Entry
    let written: Option<Array<Bool>> = None
    private done: Bool = false

    init(entry: Entry) {
        this.entry = entry
        this.written = if (!entry.readable) {
            Array<Bool>(false: item: valueCount)
        }
    }

    func detach(): Unit {
        if (refEq(entry.currentEditor, this)) {
            for (i in 0..valueCount) {
                try {
                    fileSystem.delete(entry.dirtyFiles[i])
                } catch ( e: IOException) {
                    // This file is potentially leaked. Not much we can do about that
                }
            }
            entry.currentEditor = None
        }
    }



}

private class Entry {
    let key: String
    var currentEditor: Option<Editor> = None
    let lengths: Array<Int64>
    let cleanFiles: Array<String>
    let dirtyFiles: Array<String>
    var readable: Bool = false
    var sequenceNumber: Int64 = 0

    init (key: String) {
        this.key = key
        lengths = Array<Int64>(valueCount, item: 0)
        cleanFiles = Array<String>(valueCount, item: "")
        dirtyFiles = Array<String>(valueCount, item: "")
        let sb = StringBuilder(key).append('.')
        let truncateTo = sb.size
        for (i in 0..valueCount) {
            sb.append(i)
            cleanFiles[i] = directory.info().join(key).directoryName.getOrThrow()
            sb.append(".tmp")
            cleanFiles[i] = directory.info().join(key).directoryName.getOrThrow()
            sb = StringBuilder("${sb}".subString(0, truncateTo))
        }
    }

    func snapshot(): Snapshot {
        let cl = lengths.clone()
        let arr: ArrayList<Source> = ArrayList<Source>()
        try {
            for (i in 0..valueCount) {
               arr[i] =  fileSystem.source(cleanFiles[i])
            }
            return Snapshot(key, sequenceNumber, arr.toArray(), cl)
        }
    }

    func setLengths(strings: Array<String>) {
        if (strings.size != valueCount) {
            throw HttpException("unexpected journal line: ${strings}")
        }

        try {
            for (i in 0..strings.size) {
                lengths[i] = Int64.parse(strings[i])
            }
        } catch (e: ConvertException) {
             throw HttpException("unexpected journal line: ${strings}")
        }
    }

    func writeLengths(writer: Sink): Unit {
        for (i in lengths.size) {
            writer.write(" ".toUtf8Array())
            writer.write("${lengths[i]}".toUtf8Array())
        }
    }
}

public class Snapshot <: Resource {

    private let key: String
    private let sequenceNumber: Int64
    private let sources: Array<OkBuffer>
    private let lengths: Array<Int64>

    init(key: String, sequenceNumber: Int64, sources: Array<OkBuffer>, lengths: Array<Int64>) {
        this.key = key
        this.sequenceNumber = sequenceNumber
        this.sources = sources
        this.lengths = lengths
    }

    public func getSource(index: Int64): Source {
        return source[index]
    }

}

public class FileSystem {
    let directory: Directory

    init(directory: Directory) {
        this.directory = directory
    }
    public func source(file: File): OkBuffer {
        return OkBuffer(file)
    }

    public func sink(file: File): Sink {
        return
    }

    public func appendingSink(file: String): Sink {
        return
    }

    public func delete(name: String): Unit {
        try {
            File.delete(directory.info().join(name))
        } catch (e : IOException) {
            throw HttpException("failed to delete ${directory.info().join(name)}")
        }
    }

    public func exists(name: String): Bool {
        File.exists(directory.info().join(name))
    }

    public func rename(from: String, to: String): Unit {
        try {
            File.copy(directory.info().join(from), directory.info().join(to), true)
        } catch (e : IOException) {
            throw HttpException("failed to rename from ${directory.info().join(from)} to ${directory.info().join(to)}")
        }
}
}