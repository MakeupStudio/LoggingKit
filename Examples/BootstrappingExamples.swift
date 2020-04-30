import LoggingKit

// MARK: Default

func bootstrapLoggingSystem(level: Logger.Level) -> Box<[Log]> {
    let box = Box<[Log]>()
    LoggingSystem.bootstrap(level: level, output: box)
    return box
}

func bootstrapLoggingSystem(level: Logger.Level) -> Box<Log?> {
    LoggingSystem.bootstrap(level: level)
}

// MARK: - Custom LogOutputStream

import Foundation

struct CustomLogOutputStreamExample: LogOutputStream {
    let handle: FileHandle
    
    init(_ outputFileURL: URL) throws {
        self.handle = try FileHandle(forWritingTo: outputFileURL)
    }
    
    mutating func write(_ log: Log) {
        log.dump(to: .standardOutput)
        log.dump(to: handle)
    }
}

@discardableResult
func bootstrapLoggingSystem(level: Logger.Level, _ outputFileURL: URL)
throws -> Box<CustomLogOutputStreamExample> {
    let box = try Box<CustomLogOutputStreamExample>(.init(outputFileURL))
    LoggingSystem.bootstrap(level: level, output: box)
    return box
}
